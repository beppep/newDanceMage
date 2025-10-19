extends Enemy

func do_move(world: World):
	var offset = ALL_DIRECTIONS.pick_random()
	if world.is_empty(location + offset):
		location += offset

func get_possible_targets(world: World) -> Array[Vector2i]:
	return target_with_offsets(world, ALL_DIRECTIONS)

func target_attack(world: World, _target: Vector2i) -> Array[Vector2i]:
	return target_with_offsets(world, ALL_DIRECTIONS)
