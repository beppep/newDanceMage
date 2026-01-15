extends Spell

@export var bomb_scene: PackedScene = preload("res://scenes/units/Bomb.tscn")

func cast(caster: Unit):
	var target_cell = caster.location + caster.get_facing()
	if world.is_empty(target_cell):
		while world.is_empty(target_cell + caster.get_facing()):
			target_cell = target_cell + caster.get_facing()
		var bomb = bomb_scene.instantiate()
		world.units.add_child(bomb)
		bomb.position = caster.position
		bomb.location = target_cell
		bomb.is_tnt_barrel = false

	life_time = 8
