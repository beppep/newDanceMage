extends Spell

@export var rock_scene: PackedScene = preload("res://scenes/units/Rock.tscn")

func cast(caster: Unit, world: World):
	for direction in [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
		var target_cell = caster.location + direction
		if world.is_empty(target_cell):
			var rock = rock_scene.instantiate()
			#rock.position = target_cell*world.TILE_SIZE + Vector2i(0,-100)
			world.units.add_child(rock)
			rock.position = caster.position
			rock.location = target_cell

	queue_free()
