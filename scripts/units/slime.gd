extends Enemy

	
func do_move():
	var offset = CARDINAL_DIRECTIONS.pick_random()
	if world.is_empty(location + offset):
		location += offset

func get_possible_targets() -> Array[Vector2i]:
	return target_with_offsets(CARDINAL_DIRECTIONS)

func perform_attack_effects():
	if world.is_empty(location + attack_offsets[-1]):
		location += attack_offsets[-1]
