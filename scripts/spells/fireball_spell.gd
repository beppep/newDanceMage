extends Node

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")

var caster  # player or enemy casting the spell

func _init(_caster):
	caster = _caster
	#direction = caster.direction  # assumes your player has this (Vector2.UP, etc.)

func cast():
	for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		var fireball = fireball_scene.instantiate()
		fireball.global_position = caster.global_position
		fireball.rotation = direction.angle()  # rotate to match direction

		print(fireball)

		#fireball.caster = caster
		fireball.direction = direction.normalized()

		var main = caster.get_tree().root.get_node("World")
		var projectiles = main.get_node("Projectiles")
		projectiles.add_child(fireball)
