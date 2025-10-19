extends Spell

@export var rock_scene: PackedScene = preload("res://scenes/units/Rock.tscn")

func cast():
	for direction in [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
		var target_cell = caster.location + direction
		print("Spawning at ", target_cell)
		if world.is_empty(target_cell):
			var rock = rock_scene.instantiate()
			#rock.position = target_cell*world.TILE_SIZE + Vector2i(0,-100)
			world.units.append_unit(rock)
			rock.position = caster.position
			rock.location = target_cell

	queue_free()
