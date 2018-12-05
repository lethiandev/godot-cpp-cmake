import sys
from os import path

base_path = path.dirname(__file__)

# workaround for importing a binding_generator.py script
sys.path.insert(0, path.join(base_path, 'godot-cpp'))
import binding_generator

# require <path> parameter
if not len(sys.argv) > 1:
	raise Exception('The <path> parameter is required')

# generate godot bindings from a json file
json_file = sys.argv[1]

binding_generator.generate_bindings(json_file)
