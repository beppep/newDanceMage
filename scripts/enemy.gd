extends Unit

@export var attack_indicator := preload("res://assets/sprites/particles/attack_indicator.png")
var attack_power
var attack_targets: Array[Vector2i] = []:
	set(val):
		attack_targets = val
		queue_redraw()

func _draw():
	print(attack_targets)
	for target in attack_targets:
		draw_texture(attack_indicator, World.loc_to_pos(target - location))

func process_turn(world: World):
	if not attack_targets.is_empty():
		print("Enemy attacks.")
		for target in attack_targets:
			var unit = world.units.get_unit_at(target)
			if unit:
				unit.take_damage(1)
		attack_targets = []
		anim.play("default")
	elif is_adjacent_to(world.player.location):
		print("Enemy winds up for attack.")
		attack_targets = [world.player.location]
		anim.play("windup")
	else:
		print("Enemy runs like a little coward.")
		if world.player.move_history.size() >= 2:
			var move = world.player.move_history[-2]
			if move:
				location -= move
			anim.play("default")
	turn_done.emit()
