extends Enemy


func should_attack(target):
	return target is Player or target is Egg
	
	
func do_move():
	var offset = ALL_DIRECTIONS.pick_random()
	move_to(location + offset)

func get_possible_targets() -> Array[Vector2i]:
	return target_with_offsets(ALL_DIRECTIONS)

func get_attack_offsets(_target: Vector2i) -> Array[Vector2i]:
	return target_with_offsets(ALL_DIRECTIONS)


func perform_attack_effects():
	world.particles.make_cloud(location, "ectoplasm")
