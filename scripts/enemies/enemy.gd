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

@export var attack_indicator := preload("res://assets/sprites/particles/attack_indicator.png")
var attack_power := 1
var attack_range := 1

var attack_targets: Array[Vector2i] = []:
	set(val):
		attack_targets = val
		queue_redraw()

func _draw():
	for target in attack_targets:
		draw_texture(attack_indicator, World.loc_to_pos(target - location))

@abstract func get_possible_targets(world: World) -> Array[Vector2i]
@abstract func target_attack(world: World, target: Vector2i) -> Array[Vector2i]
@abstract func do_move(world: World)

func target_with_offsets(world: World, offsets: Array[Vector2i]) -> Array[Vector2i]:
	var targets: Array[Vector2i] = []
	for offset in offsets:
		var target = location + offset
		if world.is_wall_at(target):
			continue
		targets.append(target)
	return targets

func target_with_directions(world: World, directions: Array[Vector2i]) -> Array[Vector2i]:
	var targets: Array[Vector2i] = []
	for direction in directions:
		for i in range(1, attack_range + 1):
			var target = location + direction * i
			if world.is_wall_at(target):
				break
			targets.append(target)
	return targets

func perform_attack(_world: World):
	pass

func process_turn(world: World):
	if not attack_targets.is_empty():
		print(name, " attacks.")
		for target in attack_targets:
			var unit = world.units.get_unit_at(target)
			if unit:
				unit.take_damage(attack_power)
		perform_attack(world)
		attack_targets = []
		anim.play("default")

	elif get_possible_targets(world).has(world.player.location):
		print(name, " winds up for attack.")
		attack_targets = target_attack(world, world.player.location)
		anim.play("windup")

	else:
		do_move(world)
		anim.play("default")
	turn_done.emit()
