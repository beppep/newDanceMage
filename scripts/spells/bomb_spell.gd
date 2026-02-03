extends Spell

const bomb_scene: PackedScene = preload("res://scenes/units/Bomb.tscn")

func cast(caster: Unit):
	var directions = [caster.get_facing()]
	if caster.items.get("four_way_shot", 0):
		directions = [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]
	for direction in directions:
		var target_cell = caster.location + direction
		if world.is_empty(target_cell):
			while world.is_empty(target_cell + direction):
				target_cell = target_cell + direction
			var bomb = bomb_scene.instantiate()
			world.units.add_child(bomb)
			bomb.position = caster.position
			bomb.location = target_cell
			bomb.is_tnt_barrel = false

	life_time = 8
