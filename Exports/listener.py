import sys
import os
import sqlite3
import socket
import json
import threading
from datetime import datetime, timezone

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

import grpc
from dcs.mission.v0 import mission_pb2, mission_pb2_grpc

# ── Config ────────────────────────────────────────────────────────────────────
GRPC_HOST = "localhost"
GRPC_PORT = 50051
UDP_HOST  = "127.0.0.1"
UDP_PORT  = 9876

# ── Database ──────────────────────────────────────────────────────────────────
DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "dcs_events.db")

conn    = sqlite3.connect(DB_PATH, check_same_thread=False)
db_lock = threading.Lock()

with db_lock:
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS slot_events (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            mission_time REAL,
            recorded_at  TEXT,
            event_type   TEXT,   -- SLOT_IN, TAKEOFF, LAND
            pilot        TEXT,
            unit         TEXT,
            unit_type    TEXT,
            airbase      TEXT    -- only for TAKEOFF / LAND
        );
        CREATE TABLE IF NOT EXISTS weapon_fired (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            mission_time REAL,
            recorded_at  TEXT,
            pilot        TEXT,
            unit         TEXT,
            unit_type    TEXT,
            weapon       TEXT,
            source       TEXT
        );
        CREATE TABLE IF NOT EXISTS weapon_hit (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            mission_time REAL,
            recorded_at  TEXT,
            pilot        TEXT,
            unit         TEXT,
            unit_type    TEXT,
            weapon       TEXT,
            target       TEXT,
            target_type  TEXT,
            source       TEXT
        );
    """)
    conn.commit()

# ── Helpers ───────────────────────────────────────────────────────────────────

def now_utc():
    return datetime.now(timezone.utc).isoformat()

def db(sql, params):
    with db_lock:
        conn.execute(sql, params)
        conn.commit()

# ── UDP listener — handles all Lua events ────────────────────────────────────

def udp_listener():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((UDP_HOST, UDP_PORT))
    sock.settimeout(1.0)
    print(f"[UDP]  Listening on {UDP_HOST}:{UDP_PORT}")

    while True:
        try:
            data, _ = sock.recvfrom(4096)
        except socket.timeout:
            continue
        except Exception as e:
            print(f"[UDP]  Socket error: {e}")
            break

        try:
            ev    = json.loads(data.decode("utf-8"))
            ts    = now_utc()
            etype = ev.get("type", "")
            mtime = ev.get("mission_time", 0)
            pilot = ev.get("pilot", "unknown")
            unit  = ev.get("unit",  "unknown")
            utype = ev.get("unit_type", "unknown")

            if etype == "SLOT_IN":
                db("INSERT INTO slot_events (mission_time,recorded_at,event_type,pilot,unit,unit_type) VALUES (?,?,?,?,?,?)",
                   (mtime, ts, "SLOT_IN", pilot, unit, utype))
                print(f"[SLOT]    {pilot:20s} → {unit} ({utype})")

            elif etype == "TAKEOFF":
                airbase = ev.get("airbase", "unknown")
                db("INSERT INTO slot_events (mission_time,recorded_at,event_type,pilot,unit,unit_type,airbase) VALUES (?,?,?,?,?,?,?)",
                   (mtime, ts, "TAKEOFF", pilot, unit, utype, airbase))
                print(f"[TAKEOFF] {pilot:20s} | {unit:25s} from {airbase}")

            elif etype == "LAND":
                airbase = ev.get("airbase", "unknown")
                db("INSERT INTO slot_events (mission_time,recorded_at,event_type,pilot,unit,unit_type,airbase) VALUES (?,?,?,?,?,?,?)",
                   (mtime, ts, "LAND", pilot, unit, utype, airbase))
                print(f"[LAND]    {pilot:20s} | {unit:25s} at {airbase}")

            elif etype == "SHOT":
                weapon = ev.get("weapon", "unknown")
                db("INSERT INTO weapon_fired (mission_time,recorded_at,pilot,unit,unit_type,weapon,source) VALUES (?,?,?,?,?,?,?)",
                   (mtime, ts, pilot, unit, utype, weapon, "lua_udp"))
                print(f"[FIRED]   {pilot:20s} | {unit:25s} | {weapon}")

            elif etype == "HIT":
                weapon  = ev.get("weapon",      "unknown")
                target  = ev.get("target",      "unknown")
                ttype   = ev.get("target_type", "unknown")
                db("INSERT INTO weapon_hit (mission_time,recorded_at,pilot,unit,unit_type,weapon,target,target_type,source) VALUES (?,?,?,?,?,?,?,?,?)",
                   (mtime, ts, pilot, unit, utype, weapon, target, ttype, "lua_udp"))
                print(f"[HIT]     {pilot:20s} | {unit:25s} | {weapon:18s} → {target} ({ttype})")

        except (json.JSONDecodeError, KeyError) as e:
            print(f"[UDP]  Bad packet: {e}")

# ── gRPC listener — kill confirmation only ────────────────────────────────────

def get_pilot(initiator):
    try:
        n = initiator.unit.player_name
        return n if n else "AI"
    except Exception:
        return "AI"

def get_unit(initiator):
    try:
        return initiator.unit.name or "unknown"
    except Exception:
        return "unknown"

def get_unit_type(initiator):
    try:
        return initiator.unit.type or "unknown"
    except Exception:
        return "unknown"

def get_target(target):
    try:
        which = target.WhichOneof("target")
        if which == "unit":   return target.unit.name or "unknown"
        if which == "static": return target.static.name or "unknown"
        if which == "scenery":return target.scenery.name or "unknown"
    except Exception:
        pass
    return "unknown"

def get_weapon(e):
    try:
        if hasattr(e, "weapon_name") and e.weapon_name: return e.weapon_name
    except Exception:
        pass
    try:
        return e.weapon.type or "unknown"
    except Exception:
        return "unknown"

def grpc_listener():
    address = f"{GRPC_HOST}:{GRPC_PORT}"
    print(f"[gRPC] Connecting to {address}")
    channel = grpc.insecure_channel(address)
    stub    = mission_pb2_grpc.MissionServiceStub(channel)
    print(f"[gRPC] Streaming kill events...\n")

    try:
        for response in stub.StreamEvents(mission_pb2.StreamEventsRequest()):
            ts    = now_utc()
            etype = response.WhichOneof("event")
            mtime = response.time

            if etype == "kill":
                e      = response.kill
                pilot  = get_pilot(e.initiator)
                unit   = get_unit(e.initiator)
                utype  = get_unit_type(e.initiator)
                weapon = get_weapon(e)
                target = get_target(e.target)
                db("INSERT INTO weapon_hit (mission_time,recorded_at,pilot,unit,unit_type,weapon,target,target_type,source) VALUES (?,?,?,?,?,?,?,?,?)",
                   (mtime, ts, pilot, unit, utype, weapon, target, "unknown", "grpc_kill"))
                print(f"[KILL]    {pilot:20s} | {unit:25s} | {weapon:18s} → {target}")

            elif etype == "shooting_start":
                e      = response.shooting_start
                pilot  = get_pilot(e.initiator)
                unit   = get_unit(e.initiator)
                utype  = get_unit_type(e.initiator)
                weapon = e.weapon_name or "gun"
                db("INSERT INTO weapon_fired (mission_time,recorded_at,pilot,unit,unit_type,weapon,source) VALUES (?,?,?,?,?,?,?)",
                   (mtime, ts, pilot, unit, utype, f"GUN:{weapon}", "grpc_gun"))
                print(f"[GUN]     {pilot:20s} | {unit:25s} | {weapon}")

    except grpc.RpcError as e:
        code = e.code()
        if code == grpc.StatusCode.UNAVAILABLE:
            print(f"\n[gRPC] Cannot reach {address} — is DCS running?")
        else:
            print(f"\n[gRPC] Error {code}: {e.details()}")
    except Exception as e:
        print(f"\n[gRPC] Unexpected: {e}")

# ── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("  DCS Event Listener")
    print(f"  UDP  port {UDP_PORT}  → slot-in / takeoff / land / shot / hit")
    print(f"  gRPC port {GRPC_PORT} → kill confirmation / gun")
    print("=" * 60 + "\n")

    udp_thread = threading.Thread(target=udp_listener, daemon=True)
    udp_thread.start()

    try:
        grpc_listener()
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        conn.close()