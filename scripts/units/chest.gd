extends Unit
class_name Chest

@export var bomb_scene: PackedScene = preload("res://scenes/units/Bomb.tscn")



func die():
	super()
	if randf() < 0.9:
		world.items.spawn_random_item_at(location)
	elif randf() < 0.9:
		world.floor_tilemap.set_cell(location, Globals.tile_ids["DIAMOND"], Vector2i.ZERO)
	else:
		var bomb = bomb_scene.instantiate()
		world.units.add_child(bomb)
		bomb.position = position
		bomb.location = location
		bomb.is_tnt_barrel = false
	
