extends Node
class_name Items

@onready var world = get_parent()

const ALL_ITEM_PATHS : Array = [
	"res://assets/resources/items/bomb_immune.tres",
	"res://assets/resources/items/exploding_rocks.tres",
	"res://assets/resources/items/heart.tres",
	"res://assets/resources/items/push.tres",
]


func create_item(item_resource : Item):
	var item_node = Sprite2D.new()
	item_node.texture = item_resource.image

func get_item_at(location):
	for item in get_children():
		if world.pos_to_loc(item.position) == location and not item.is_queued_for_deletion():
			return item

func pickup_item_at(location, _player):
	var item_node = get_item_at(location)
	if item_node:
		item_node.pick_up(_player)
		item_node.queue_free()
	
	
func spawn_random_item_at(loc):
	var item_resource: ItemResource = load(ALL_ITEM_PATHS.pick_random())
	var item_node = Item.new()
	item_node.item_resource = item_resource
	var sprite_node = Sprite2D.new()
	item_node.add_child(sprite_node)
	sprite_node.texture = item_resource.image
	item_node.location = loc
	add_child(item_node)
