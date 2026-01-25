extends Node
class_name Items

@onready var world = get_parent()

static var unspawned_items : Array = [
	preload("res://assets/resources/items/bomb_immune.tres"),
	preload("res://assets/resources/items/exploding_rocks.tres"),
	preload("res://assets/resources/items/heart.tres"),
	preload("res://assets/resources/items/push.tres"),
	preload("res://assets/resources/items/walk_damage.tres"),
	preload("res://assets/resources/items/strange_spoon.tres"),
	preload("res://assets/resources/items/metal_shoe.tres"),
	preload("res://assets/resources/items/recipe_shuffler.tres"),
]


func get_item_at(location):
	for item in get_children():
		if world.pos_to_loc(item.position) == location and not item.is_queued_for_deletion():
			return item

func pickup_item_at(location, _player):
	var item_node = get_item_at(location)
	if item_node:
		item_node.pick_up(_player)
		item_node.queue_free()

static func choose_random_item(): # this also removes it from pool
	var item_resource: ItemResource = unspawned_items.pick_random()
	if item_resource.name=="recipe_shuffler" and randf()<0.5:
		item_resource = preload("res://assets/resources/items/heart.tres")
	if not item_resource.stackable:
		unspawned_items.erase(item_resource)
		#print("remianing items : ", ALL_ITEM_PATHS.size())
	return item_resource
	
	
func spawn_item_at(loc, item_resource : ItemResource):
	var item_node = Item.new()
	item_node.item_resource = item_resource
	var sprite_node = Sprite2D.new()
	sprite_node.texture = item_resource.image
	item_node.position = World.loc_to_pos(loc)
	item_node.location = loc
	item_node.add_child(sprite_node)
	add_child(item_node)
	
func spawn_random_item_at(loc):
	spawn_item_at(loc, choose_random_item())
	
