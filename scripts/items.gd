extends Node

@onready var world = get_parent()


func create_item(item_resource : Item):
	var item_node = Sprite2D.new()
	item_node.texture = item_resource.image

func get_item(location):
	for item in get_children():
		if world.pos_to_loc(item.position) == location:
			return item
	
