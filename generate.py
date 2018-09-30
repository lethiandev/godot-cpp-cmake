import sys
from os import path

base_path = path.dirname(__file__)

# workaround for importing a binding_generator.py script
sys.path.insert(0, path.join(base_path, 'godot-cpp'))
import binding_generator

# generate godot bindings from a json file
json_file = path.join(base_path, 'godot-cpp/godot_api.json')

if len(sys.argv) > 1:
	json_file = sys.argv[1]

binding_generator.generate_bindings(json_file)
