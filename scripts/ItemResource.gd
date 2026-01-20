extends Resource
class_name ItemResource

@export_category("Item")

@export var name: String = "Some Cool Display Name"
@export var dev_name: String = "item_123"
@export var image: Texture2D
@export var description: String = "Does something cool"
@export var price: int = 4
@export var pickup_script: Script
@export var stackable = false

func pickup(player : Player): #useless?
	player.items[name] = player.items.get(dev_name, 0) + 1
	match dev_name:
		"heart":
			player.max_health += 1
			player.health += 1
