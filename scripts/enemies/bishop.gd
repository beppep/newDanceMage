extends Enemy

func _ready() -> void:
	attack_range = 7

func do_move(world: World):
	var offset = DIAGONAL_DIRECTIONS.pick_random()
	move_in_direction(world, offset)

func get_possible_targets(world: World) -> Array[Vector2i]:
	return target_with_directions(world, DIAGONAL_DIRECTIONS)

func target_attack(world: World, target: Vector2i) -> Array[Vector2i]:
	var direction: Vector2i = (target - location) / abs(target.x - location.x)
	return target_with_directions(world, [direction])

func perform_attack(world: World):
	var offset = attack_targets.front()
	var direction: Vector2i = (offset - location) / abs(offset.x - location.x)
	move_in_direction(world, direction, attack_range)
