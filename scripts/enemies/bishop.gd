extends Enemy

func _ready() -> void:
	attack_range = 7

func do_move(world: World):
	var offset = DIAGONAL_DIRECTIONS.pick_random()
	if not world.is_empty(location + offset):
		offset = DIAGONAL_DIRECTIONS.pick_random() # 2 tries
	move_in_direction(world, offset)

func get_possible_targets(world: World) -> Array[Vector2i]:
	return target_with_directions(world, DIAGONAL_DIRECTIONS)

func target_attack(world: World, target: Vector2i) -> Array[Vector2i]:
	var direction: Vector2i = Vector2i( -1 if (target.x<location.x+randf()) else 1, -1 if (target.y<location.y+randf()) else 1 )
	return target_with_directions(world, [direction])

func perform_attack(world: World):
	var offset = attack_targets.front()
	var direction: Vector2i = (offset - location) / abs(offset.x - location.x)
	move_in_direction(world, direction, attack_range)
