extends Node

@export var fireball_scene: PackedScene = preload("res://spells/fireball.tscn")

var caster  # player or enemy casting the spell
var direction := Vector2.ZERO

func _init(_caster):
	caster = _caster
	direction = caster.direction  # assumes your player has this (Vector2.UP, etc.)

func cast():
	var fireball = fireball_scene.instantiate()
	fireball.global_position = caster.global_position
	fireball.rotation = direction.angle()  # rotate to match direction

	# Optional: make the fireball know who shot it
	fireball.caster = caster
	fireball.direction = direction.normalized()

	get_tree().current_scene.add_child(fireball)
