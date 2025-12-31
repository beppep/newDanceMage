extends Enemy

func _ready() -> void:
	super()
	attack_range = 7
	speed = 500.0

func do_move():
	var offset = DIAGONAL_DIRECTIONS.pick_random()
	if not world.is_empty(location + offset):
		offset = DIAGONAL_DIRECTIONS.pick_random() # 2 tries
	move_in_direction(offset)

func get_possible_targets() -> Array[Vector2i]:
	return target_with_directions(DIAGONAL_DIRECTIONS)

func get_attack_offsets(offset: Vector2i) -> Array[Vector2i]:
	var direction: Vector2i = offset / abs(offset.x)
	return target_with_directions([direction])

func perform_attack():
	var offset = attack_offsets.back()
	var direction: Vector2i = offset / abs(offset.x)
	perform_moving_attack(direction, abs(offset.x))
