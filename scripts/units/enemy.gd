@abstract
extends Unit
class_name Enemy

const CARDINAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
]
const DIAGONAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP + Vector2i.LEFT,
	Vector2i.UP + Vector2i.RIGHT,
	Vector2i.DOWN + Vector2i.LEFT,
	Vector2i.DOWN + Vector2i.RIGHT,
]
const ALL_DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP + Vector2i.LEFT,
	Vector2i.UP + Vector2i.RIGHT,
	Vector2i.DOWN + Vector2i.LEFT,
	Vector2i.DOWN + Vector2i.RIGHT,
]

var attack_indicator := preload("res://assets/sprites/particles/attack_indicator.png")
var attack_power := 1
var attack_range := 1

var attack_offsets: Array[Vector2i] = []:
	set(val):
		attack_offsets = val
		if val:
			anim.play("windup")
		else:
			anim.play("default")
		queue_redraw()

@abstract func get_possible_targets() -> Array[Vector2i]
@abstract func do_move()

func get_attack_offsets(offset: Vector2i) -> Array[Vector2i]:
	return [offset]

func perform_attack_effects():
	pass

func _draw():
	print("frozen ",frozen)
	if frozen:
		return
	for target in attack_offsets:
		draw_texture(attack_indicator, World.loc_to_pos(target - Vector2i(1, 1)))

func target_with_offsets(offsets: Array[Vector2i]) -> Array[Vector2i]:
	var targets: Array[Vector2i] = []
	for offset in offsets:
		var target = location + offset
		if world.is_wall_at(target):
			continue
		targets.append(offset)
	return targets

func target_with_directions(directions: Array[Vector2i]) -> Array[Vector2i]:
	var targets: Array[Vector2i] = []
	for direction in directions:
		for i in range(1, attack_range + 1):
			var target = location + direction * i
			if world.is_wall_at(target):
				break
			targets.append(direction * i)
	return targets

func get_unit_in_direction(direction: Vector2i, length: int = 1) -> Unit:
	return world.get_closest_unit(location, direction, length)

func perform_moving_attack(offset: Vector2i, length: int = 1):
	if world.is_wall_at(location + offset):
		return

	attack_offsets = []

	var unit = get_unit_in_direction(offset, length)

	if unit:
		location = unit.location
		# Play hitting particle animation
		var p = Particles.new()
		add_child(p)
		p.make_particle_cloud_at(World.loc_to_pos(location), "smoke")
		# Move back one step if unit will still be alive after attack
		if unit.health > attack_power:
			location -= offset
		unit.take_damage(attack_power)
	else:
		move_in_direction(offset, length)

func perform_attack():
	print(name, " attacks.")
	var targets = attack_offsets.map(func (offset): return location + offset)
	for target in targets:
		world.deal_damage_at(target, attack_power)
	perform_attack_effects()
	attack_offsets = []


func process_turn():
		
	if not attack_offsets.is_empty():
		perform_attack()
		return

	var possible_targets = get_possible_targets()
	if possible_targets.has(world.player.location - location):
		print(name, " winds up for attack.")
		attack_offsets = get_attack_offsets(world.player.location - location)
	elif randf() < 0.3:
		for offset in possible_targets:
			var target = location + offset
			if target.distance_squared_to(world.player.location) <= 1:
				attack_offsets = get_attack_offsets(offset)
				break
	

	if not attack_offsets:
		do_move()
