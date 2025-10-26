extends Enemy

var offsets := get_offsets()

func get_offsets() -> Array[Vector2i]:
	var offs: Array[Vector2i] = []
	for direction in CARDINAL_DIRECTIONS:
		for small_dir in [rotate90(direction), -rotate90(direction)]:
			offs.append(direction * 2 + small_dir)
	return offs

func rotate90(p: Vector2i) -> Vector2i:
	return Vector2i(p.y, -p.x)

func do_move():
	var offset = offsets.pick_random()
	if world.is_empty(location + offset):
		location += offset

func get_possible_targets() -> Array[Vector2i]:
	return target_with_offsets(offsets)

func perform_attack_effects():
	var offset = attack_offsets.front()
	if world.is_empty(location + offset):
		location += offset
