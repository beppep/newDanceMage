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
			shaking = true
		else:
			shaking = false
			anim.play("default")
		queue_redraw()

@abstract func get_possible_targets() -> Array[Vector2i] # used to check if it should attack

var indicator_drawer: Node2D

func _ready():
	super()
	indicator_drawer = Node2D.new()
	add_child(indicator_drawer)
	indicator_drawer.z_index = -1      # always below the enemy
	


func should_attack(target) -> bool:
	return target is Player or target == null # true for player and null

func get_attack_offsets(offset: Vector2i) -> Array[Vector2i]: # get the rest of the attack offsets for a given target??
	return [offset]

func perform_attack_effects():
	pass
	

func do_move():
	var offset = CARDINAL_DIRECTIONS.pick_random() #no. they are smarter now;
	if randf()< 0.5 and world.player.location.x != location.x:
		if world.player.location.x < location.x:
			offset = Vector2i(-1,0)
		else:
			offset = Vector2i(1,0)
	else:
		if world.player.location.y < location.y:
			offset = Vector2i(0,-1)
		else:
			offset = Vector2i(0,1)
		
	if world.is_empty(location + offset):
		location += offset

func _draw():
	#print("frozen ",frozen)
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
			if world.units.get_unit_at(target):
				if world.units.get_unit_at(target) != world.player:
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
		if true:# should_attack(unit): 
			world.particles.make_cloud(location, "smoke")
			# Move back one step if unit will still be alive after attack
			if unit.health > attack_power:
				location -= offset
			unit.take_damage(attack_power)
		else:
			# Move back one step if you wont kill that type of unit
			location -= offset
	else:
		move_in_direction(offset, length)

func perform_attack():
	print(name, " attacks.")
	var targets = attack_offsets.map(func (offset): return location + offset)
	for target in targets:
		if not world.units.get_unit_at(target) is Crystal and should_attack(world.units.get_unit_at(target)):
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
		possible_targets.shuffle()
		for offset in possible_targets:
			var target = location + offset
			if target.distance_squared_to(world.player.location) <= 3 and should_attack(world.units.get_unit_at(target)):
				attack_offsets = get_attack_offsets(offset)
				break
	

	if not attack_offsets:
		do_move()



func die():
	super()
	#if randf() < 0.9:
	#	world.floor_tilemap.set_cell(location, 2, Vector2i(0,0))
	if randf() < 0.1:
		world.floor_tilemap.set_cell(location, 1, Vector2i(0,0)) # heart
		
