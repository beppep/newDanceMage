extends Spell

@export var bomb_scene: PackedScene = preload("res://scenes/units/Bomb.tscn")

func cast(caster: Unit):
	var target_cell = caster.location + caster.get_facing()
	if world.is_empty(target_cell):
		while world.is_empty(target_cell + caster.get_facing()):
			target_cell = target_cell + caster.get_facing()
		var bomb = bomb_scene.instantiate()
		#rock.position = target_cell*world.TILE_SIZE + Vector2i(0,-100)
		world.units.add_child(bomb)
		bomb.position = caster.position
		bomb.location = target_cell

	queue_free()
