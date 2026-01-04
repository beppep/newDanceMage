extends Enemy


# fix ATTACK DIRECTIONS being all diagonals

const ROOK_SCENE: PackedScene = preload("res://scenes/enemies/rook.tscn")

var pawn_direction : Vector2i = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT].pick_random()
#var attack_directions : Array[Vector2i] = ([pawn_direction + Vector2i.UP, pawn_direction + Vector2i.DOWN] if pawn_direction.x==0 else [pawn_direction + Vector2i.LEFT, pawn_direction + Vector2i.RIGHT]) as Array[Vector2i] # doesnt work
var first_move = true

func do_move():
	if world.is_empty(location + pawn_direction):
		var twostepschance = 0.5
		location += pawn_direction
		if first_move and (randf()<twostepschance) and world.is_empty(location + pawn_direction):
			location += pawn_direction
			first_move = false
	elif world.units.get_unit_at(location+pawn_direction)==null:
		var rook = ROOK_SCENE.instantiate()
		rook.location = location
		rook.position = position
		world.units.add_child(rook)
		queue_free()

func get_possible_targets() -> Array[Vector2i]:
	#return target_with_offsets(attack_directions)
	return target_with_offsets(DIAGONAL_DIRECTIONS)

func perform_attack():
	var offset = attack_offsets.front()
	perform_moving_attack(offset)

func perform_attack_effects():
	var offset = attack_offsets.front()
	if world.is_empty(location + offset):
		location += offset
