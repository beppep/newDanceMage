extends Node

# helps in the transition from character_select -> main_scene
var selected_character : CharacterResource



# lookup table for tileset ids. used in mapgen and world
var tile_ids = {"OBSIDIAN":0, "STONE":1, "SAND":2, "WOOD":3 ,"STAIRS":4, "WHITE":5, "BLACK":6, "SPIKES":7, "NOSPIKES":8, "HEART":1, "COIN":2} # SKETCHY because it has to align with the tileset at all times





# tried to find fatness of an enemy before spawning it. rip
func get_attribute_from_packed_scene(packed_scene, attribute_name): # godot moment
	var state_thingy = packed_scene.get_state()
	for i in range(state_thingy.get_node_property_count(0)):
		print(state_thingy.get_node_property_name(0,i))
		if state_thingy.get_node_property_name(0,i)==attribute_name: #wtf is this interface. by int? rly?
			return state_thingy.get_node_property_value(0,i)
			#and it doest even work wtf man
