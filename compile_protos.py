import glob
import subprocess
import sys

# Grab all .proto files in the protos folder
proto_files = glob.glob('protos/**/*.proto', recursive=True)

if not proto_files:
    print("No .proto files found in the 'protos' folder!")
    sys.exit(1)

# Build the protoc command
command = [
    sys.executable, 
    '-m', 'grpc_tools.protoc', 
    '-I./protos', 
    '--python_out=./protos', 
    '--grpc_python_out=./protos'
] + proto_files

# Run the command
print(f"Compiling {len(proto_files)} proto files...")
subprocess.run(command)
print("Done! You should now see the _pb2.py files in your folder.")
