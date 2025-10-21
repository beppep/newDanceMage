extends Enemy

func _ready() -> void:
	attack_range = 7
	speed = 500.0

func do_move(world: World):
	var offset = DIAGONAL_DIRECTIONS.pick_random()
	if not world.is_empty(location + offset):
		offset = DIAGONAL_DIRECTIONS.pick_random() # 2 tries
	move_in_direction(world, offset)

func get_possible_targets(world: World) -> Array[Vector2i]:
	return target_with_directions(world, DIAGONAL_DIRECTIONS)

func get_attack_offsets(world: World, offset: Vector2i) -> Array[Vector2i]:
	var direction: Vector2i = offset / abs(offset.x)
	return target_with_directions(world, [direction])

func perform_attack(world: World):
	var offset = attack_offsets.front()
	var direction: Vector2i = offset / abs(offset.x)
	perform_moving_attack(world, direction, attack_range)
