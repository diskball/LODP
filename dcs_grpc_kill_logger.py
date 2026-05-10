import grpc
import sqlite3
from datetime import datetime
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), 'protos'))

# These imports depend on the compiled protobuf files from dcs-grpc.
# Ensure you have compiled the .proto files using protoc and placed them in your working directory.
from dcs.mission.v0 import mission_pb2
from dcs.mission.v0 import mission_pb2_grpc

DB_FILE = "dcs_kills.db"

def setup_database():
    """Initialize the SQLite database and create the kills table if it doesn't exist."""
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS kills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            shooter_name TEXT,
            target_type TEXT,
            weapon_name TEXT
        )
    ''')
    conn.commit()
    return conn

def main():
    # Connect to database
    db_conn = setup_database()
    db_cursor = db_conn.cursor()

    # Connect to DCS-gRPC server (default port is 50051)
    channel = grpc.insecure_channel('localhost:50051')
    mission_stub = mission_pb2_grpc.MissionServiceStub(channel)

    # In-memory trackers
    # active_players tracks unit_id -> player_name
    active_players = {}
    # active_weapons tracks weapon_id -> { shooter_name, weapon_type }
    active_weapons = {}

    print("Connected to DCS-gRPC. Listening for events...")
    
    try:
        # Subscribe to the event stream
        for event in mission_stub.StreamEvents(mission_pb2.StreamEventsRequest()):
            event_type = event.WhichOneof('event')
            
            # Skip log spam from frame updates
            if event_type == 'simulation_fps':
                continue

            if event_type:
                print(f"DEBUG: Received event type -> {event_type}")

            # 1. Catch player slotting in
            if event_type == 'player_enter_unit':
                enter = event.player_enter_unit
                if enter.HasField('initiator') and enter.initiator.HasField('unit'):
                    unit_id = str(enter.initiator.unit.id)
                    player_name = enter.initiator.unit.player_name if enter.initiator.unit.player_name else "Unknown Player"
                    active_players[unit_id] = player_name
                    print(f">>> [{datetime.now().strftime('%H:%M:%S')}] PLAYER SLOTTED: {player_name} entered unit {enter.initiator.unit.name} ({enter.initiator.unit.type})")

            # 2. Catch player leaving a slot
            elif event_type == 'player_leave_unit':
                leave = event.player_leave_unit
                if leave.HasField('initiator') and leave.initiator.HasField('unit'):
                    unit_id = str(leave.initiator.unit.id)
                    player_name = active_players.pop(unit_id, leave.initiator.unit.player_name if leave.initiator.unit.player_name else "Unknown Player")
                    print(f">>> [{datetime.now().strftime('%H:%M:%S')}] PLAYER LEFT: {player_name} left unit {leave.initiator.unit.name}")

            # 2a. Catch birth events as a fallback to map player names to units
            elif event_type == 'birth':
                birth = event.birth
                if birth.HasField('initiator') and birth.initiator.HasField('unit'):
                    if birth.initiator.unit.player_name:
                        unit_id = str(birth.initiator.unit.id)
                        active_players[unit_id] = birth.initiator.unit.player_name

            # 3. Catch S_EVENT_SHOT: A player shoots a missile or drops a bomb
            elif event_type == 'shot':
                shot = event.shot
                if shot.HasField('initiator') and shot.initiator.HasField('unit'):
                    unit_id = str(shot.initiator.unit.id)
                    
                    # Cross-reference with our tracker to ensure we know who is shooting
                    player_name = active_players.get(unit_id) or shot.initiator.unit.player_name
                    
                    if player_name:
                        weapon_id = str(shot.weapon.id) if shot.HasField('weapon') else "Unknown_ID"
                        weapon_name = shot.weapon_name if shot.weapon_name else "Unknown Weapon"
                        
                        print(f">>> [{datetime.now().strftime('%H:%M:%S')}] PLAYER SHOT: {player_name} fired {weapon_name} (Weapon ID: {weapon_id})")
                        active_weapons[weapon_id] = {
                            "shooter": player_name,
                            "weapon": weapon_name
                        }

            # 4. Catch S_EVENT_KILL: A player missile/bomb destroyed a unit
            elif event_type == 'kill':
                kill = event.kill
                if kill.HasField('initiator') and kill.initiator.HasField('unit'):
                    unit_id = str(kill.initiator.unit.id)
                    player_name = active_players.get(unit_id) or kill.initiator.unit.player_name
                    
                    if player_name:
                        target_type = "Unknown Target"
                        if kill.HasField('target'):
                            if kill.target.HasField('unit'):
                                target_type = kill.target.unit.type
                            elif kill.target.HasField('scenery'):
                                target_type = "Scenery Object"
                        
                        weapon_name = kill.weapon_name if kill.weapon_name else "Unknown Weapon"
                        print(f">>> [{datetime.now().strftime('%H:%M:%S')}] PLAYER KILL RECORDED: {player_name} killed {target_type} with {weapon_name}")
                        
                        db_cursor.execute(
                            "INSERT INTO kills (timestamp, shooter_name, target_type, weapon_name) VALUES (datetime('now', 'localtime'), ?, ?, ?)",
                            (player_name, target_type, weapon_name)
                        )
                        db_conn.commit()

            # 5. Catch S_EVENT_HIT: A weapon impacts a target
            elif event_type == 'hit':
                hit = event.hit
                weapon_id = str(hit.weapon.id) if hit.HasField('weapon') else "Unknown_ID"
                
                # Check if this weapon was tracked from a player's 'shot' event
                if weapon_id in active_weapons:
                    shooter = active_weapons[weapon_id]["shooter"]
                    weapon_name = active_weapons[weapon_id]["weapon"]
                    
                    target_name = "Unknown Target / Scenery"
                    if hit.HasField('target'):
                        if hit.target.HasField('unit'):
                            target_name = f"{hit.target.unit.type} ({hit.target.unit.name})"
                        elif hit.target.HasField('scenery'):
                            target_name = "Scenery Object"
                            
                    print(f">>> [{datetime.now().strftime('%H:%M:%S')}] PLAYER HIT: {shooter} hit {target_name} with {weapon_name}")

            # Ignore spammy and empty events to keep logs clean
            elif event_type in ['shooting_start', 'shooting_end', 'unit_lost', 'human_failure', 'pilot_dead', 'crash', 'takeoff', 'land', 'engine_startup', 'engine_shutdown', 'weapon_add', 'player_change_slot', 'score']:
                pass
            else:
                # Print raw structure of other events to discover their exact field names
                print(f"--- RAW EVENT ({event_type}) ---\n{event}")

    except KeyboardInterrupt:
        print("Stopping logger...")
        db_conn.close()

if __name__ == '__main__':
    main()
