extends Spell

@export var projectile_scene: PackedScene = preload("res://scenes/particles/Projectile.tscn")


func cast(caster: Unit):
	var directions = []#caster.get_facing()
	#if caster.items.get("four_way_shot", 0):
	directions = [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]
	for direction in directions:
		var fireball = projectile_scene.instantiate()
		#fireball.global_position = caster.global_position
		fireball.rotation = Vector2(direction).angle()  # rotate to match direction
		fireball.direction = direction
		fireball.caster = caster
		add_child(fireball)


func _physics_process(_delta): # dies when children die
	if get_child_count() == 0:
		queue_free()
