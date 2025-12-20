extends Node


func get_attribute_from_packed_scene(packed_scene, attribute_name): # godot moment
	var state_thingy = packed_scene.get_state()
	for i in range(state_thingy.get_node_property_count(0)):
		print(state_thingy.get_node_property_name(0,i))
		if state_thingy.get_node_property_name(0,i)==attribute_name: #wtf is this interface. by int? rly?
			return state_thingy.get_node_property_value(0,i)
			
			#and it doest even work wtf man
