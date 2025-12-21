extends Spell

@export var bomb_scene: PackedScene = preload("res://scenes/units/Bomb.tscn")

func _ready():
	super()
	life_time = 8

func cast(caster: Unit):
	caster.extra_turn = 1
