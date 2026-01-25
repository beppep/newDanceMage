extends Enemy
class_name Slime

	

func get_possible_targets() -> Array[Vector2i]:
	return target_with_offsets(CARDINAL_DIRECTIONS)

func perform_attack_effects():
	if world.is_empty(location + attack_offsets[-1]):
		location += attack_offsets[-1]
	else:
		location += attack_offsets[-1]
		location -= attack_offsets[-1]
