extends Spell

@export var bomb_scene: PackedScene = preload("res://scenes/units/Bomb.tscn")

func cast(caster: Unit):
	caster.extra_turn += 1
	life_time = 8
