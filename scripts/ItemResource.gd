extends Resource
class_name Item
@export_category("Item")

@export var name: String = "Some Cool Item"
@export var image: Texture2D
@export var description: String = "Some cool item that does something cool"
@export var price: int = 4
@export var pickup_script: Script

func pickup(player : Player):
	player.items[name] = player.items.get(name, 0) + 1
	match name:
		"heart":
			player.max_health += 1
			player.health += 1
