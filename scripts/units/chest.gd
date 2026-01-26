extends Unit
class_name Chest

@export var bomb_scene: PackedScene = preload("res://scenes/units/Bomb.tscn")



func die():
	super()
	if randf() < 0.3:
		world.items.spawn_random_item_at(location)
	else:
		world.floor_tilemap.set_cell(location, Globals.tile_ids["DIAMOND"], Vector2i.ZERO)
	if randf() < 0.3:
		var bomb = bomb_scene.instantiate()
		world.units.add_child(bomb)
		bomb.position = position
		bomb.location = location
		bomb.is_tnt_barrel = false
		
	if randf()<0.6:
		var map_generator : MapGenerator = world.get_node("map_generator")
		for i in range(3):
			var offset := Vector2i(randi_range(-2,2), randi_range(-2,2))
			if not offset==Vector2i.ZERO:
				var thing = map_generator._create_unit_at(location + offset, map_generator.skeleton_archer_scene)
				if thing:
					thing.health = randi_range(1,2)
	
