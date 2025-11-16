extends Enemy


func should_attack(target) -> bool:
	return true
	
func do_move():
	var offset = CARDINAL_DIRECTIONS.pick_random()
	if world.is_empty(location + offset):
		location += offset

func get_possible_targets() -> Array[Vector2i]:
	return target_with_offsets(CARDINAL_DIRECTIONS)

func perform_attack_effects():
	world.particles.make_cloud(location+ attack_offsets[-1], "smoke")
