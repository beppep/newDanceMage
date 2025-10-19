extends Enemy

func do_move(world: World):
	var offset = CARDINAL_DIRECTIONS.pick_random()
	if world.is_empty(location + offset):
		location += offset

func get_possible_targets(world: World) -> Array[Vector2i]:
	return target_with_offsets(world, CARDINAL_DIRECTIONS)

func target_attack(_world: World, target: Vector2i) -> Array[Vector2i]:
	return [target]
