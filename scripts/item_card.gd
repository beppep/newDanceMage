extends Control
class_name Item_card

@onready var world : World = get_tree().current_scene


@export var item: ItemResource:
	set(value):
		item = value
		$Button/VBoxContainer/title.text = item.name
		$Button/VBoxContainer/description.text = item.description
		$Button/VBoxContainer/TextureRect.texture = item.image
		$Button/VBoxContainer/cost.text = str(item.price) + "$"

func _on_button_pressed() -> void:
	if world.player.diamonds >= item.price:
		world.player.diamonds -= item.price
		item.pick_up_effects(world.player, world)
		queue_free()
	
