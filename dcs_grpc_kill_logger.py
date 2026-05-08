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
    # active_weapons tracks weapon_id -> { shooter_name, weapon_type }
    active_weapons = {}
    # pending_kills tracks target_unit_id -> { shooter_name, weapon_type }
    pending_kills = {}

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

            # 1. Catch S_EVENT_SHOT: Store who fired what weapon
            if event_type == 'shot':
                print(f"--- RAW EVENT (shot) ---\n{event}")
                shot = event.shot
                
                # Safely extract fields based on the nested protobuf structure
                weapon_id = str(shot.weapon.id) if shot.HasField('weapon') else "Unknown_ID"
                weapon_name = shot.weapon_name if shot.weapon_name else "Unknown Weapon"
                
                shooter = "Unknown"
                if shot.HasField('initiator') and shot.initiator.HasField('unit'):
                    shooter = shot.initiator.unit.name
                    
                print(f"DEBUG [SHOT]: {shooter} fired {weapon_name} (ID: {weapon_id})")
                active_weapons[weapon_id] = {
                    "shooter": shooter,
                    "weapon": weapon_name
                }

            # 2. Catch S_EVENT_HIT: Link the weapon to the target
            elif event_type == 'hit':
                print(f"--- RAW EVENT (hit) ---\n{event}")
                hit = event.hit
                
                weapon_id = str(hit.weapon.id) if hit.HasField('weapon') else "Unknown_ID"
                target_id = "Unknown"
                target_type = "Unknown"
                
                if hit.HasField('target') and hit.target.HasField('unit'):
                    target_id = str(hit.target.unit.id)
                    target_type = hit.target.unit.type
                    
                print(f"DEBUG [HIT]: Weapon {weapon_id} hit Target {target_id} ({target_type})")
                
                # If we tracked this weapon being fired, mark the target as hit by it
                if weapon_id in active_weapons and target_id != "Unknown":
                    pending_kills[target_id] = active_weapons[weapon_id]

            # 3. Catch S_EVENT_DEAD: Trigger the final database report
            elif event_type == 'dead':
                print(f"--- RAW EVENT (dead) ---\n{event}")
                dead = event.dead
                
                target_id = "Unknown"
                target_type = "Unknown"
                if dead.HasField('initiator') and dead.initiator.HasField('unit'):
                    target_id = str(dead.initiator.unit.id)
                    target_type = dead.initiator.unit.type
                    
                print(f"DEBUG [DEAD]: Unit {target_id} ({target_type}) died.")

                # Check if this dead unit was recently hit by a tracked weapon
                if target_id in pending_kills:
                    kill_data = pending_kills.pop(target_id)
                    shooter = kill_data["shooter"]
                    weapon = kill_data["weapon"]

                    print(f">>> [{datetime.now().strftime('%H:%M:%S')}] KILL RECORDED (via Dead): {shooter} killed {target_type} with {weapon} <<<")

                    # Export and save data to the database
                    db_cursor.execute(
                        "INSERT INTO kills (timestamp, shooter_name, target_type, weapon_name) VALUES (datetime('now', 'localtime'), ?, ?, ?)",
                        (shooter, target_type, weapon)
                    )
                    db_conn.commit()
                        
            # 4. Catch S_EVENT_KILL: (Alternative / Fallback) DCS often provides direct kill events
            elif event_type == 'kill':
                print(f"--- RAW EVENT (kill) ---\n{event}")
                kill = event.kill
                
                shooter = "Unknown"
                target_type = "Unknown"
                weapon = kill.weapon_name if kill.weapon_name else "Unknown Weapon"
                
                if kill.HasField('initiator') and kill.initiator.HasField('unit'):
                    shooter = kill.initiator.unit.name
                if kill.HasField('target') and kill.target.HasField('unit'):
                    target_type = kill.target.unit.type
                    
                print(f">>> [{datetime.now().strftime('%H:%M:%S')}] KILL RECORDED (via Kill): {shooter} killed {target_type} with {weapon} <<<")

                # Export and save data to the database
                db_cursor.execute(
                    "INSERT INTO kills (timestamp, shooter_name, target_type, weapon_name) VALUES (datetime('now', 'localtime'), ?, ?, ?)",
                    (shooter, target_type, weapon)
                )
                db_conn.commit()

            elif event_type in ['score', 'unit_lost']:
                # Print raw structure to see if we can extract kill data from it
                print(f"--- RAW EVENT ({event_type}) ---\n{event}")
            elif event_type not in ['human_failure', 'pilot_dead', 'crash', 'player_enter_unit', 'player_leave_unit', 'takeoff', 'land']:
                # Print raw structure of other events to discover their exact field names
                print(f"--- RAW EVENT ({event_type}) ---\n{event}")

    except KeyboardInterrupt:
        print("Stopping logger...")
        db_conn.close()

if __name__ == '__main__':
    main()
