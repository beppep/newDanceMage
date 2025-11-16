extends Spell

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")


func cast(_caster: Unit):
	for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		var fireball = fireball_scene.instantiate()
		#fireball.global_position = caster.global_position
		fireball.rotation = direction.angle()  # rotate to match direction
		fireball.direction = direction.normalized()

		add_child(fireball)


func _physics_process(_delta): # dies when children die
	if get_child_count() == 0:
		queue_free()
