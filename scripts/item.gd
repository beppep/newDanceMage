extends Node2D

@onready var world : World = $"/root/World"

var item_resource : Item

var all_items = [
	
]

func _ready():
	if not item_resource:
		item_resource = all_items.pick_random()


func pick_up():
	world.player.items[item_resource.name] = world.player.items.get(item_resource.name, 0) + 1
	match item_resource.name:
		"heart":
			world.player.max_health += 1
			world.player.health += 1
	queue_free()
