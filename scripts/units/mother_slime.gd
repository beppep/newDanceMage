extends Enemy


const SLIME_SCENE: PackedScene = preload("res://scenes/units/Slime.tscn")
const RED_SLIME_SCENE: PackedScene = preload("res://scenes/units/RedSlime.tscn")


func has_air_or_attackable(loc):
	if world.is_empty(loc):
		return true # air
	var occupant = world.units.get_unit_at(loc)
	if occupant:
		if should_attack(occupant):
			return true # attackable
		else:
			return false # not attackable
	else:
		return false # wall

var TARGET_OFFSETS = [
		[Vector2i(-1,0),Vector2i(-1,1)], # -x
		[Vector2i(0,-1),Vector2i(1,-1)], # -y
		[Vector2i(0,2), Vector2i(1,2) ], # +x
		[Vector2i(2,0), Vector2i(2,1) ], # +y
	] #lol
	

func _ready():
	super()
	max_health = 3
	health = 3
	
func do_move():
	var offset = CARDINAL_DIRECTIONS.pick_random()
	if world.is_empty(location + offset, fatness, self):
		location += offset

func get_possible_targets() -> Array[Vector2i]:
	
	# lets try to make this guy jump in cardinal directions using this framework.
	
	# step 1: filter out the jumps that are possible
	var possible_jumps = []
	for offsets in TARGET_OFFSETS:
		possible_jumps.append(offsets)
		for offset in offsets:
			if not has_air_or_attackable(location+offset):
				possible_jumps.erase(offsets)
	
	# step 2: flatten
	var possible_targets : Array[Vector2i] = []
	possible_jumps.map(func(a): possible_targets.append_array(a))
	
	return target_with_offsets(possible_targets)

func perform_attack_effects():
	var move_direction = attack_offsets[0]/abs(attack_offsets[0].x+attack_offsets[0].y) # hack to find jump vector
	if world.is_empty(location + attack_offsets[0]) and world.is_empty(location + attack_offsets[1]):
		location += move_direction
	else:
		location += move_direction
		location -= move_direction
		

func get_attack_offsets(offset: Vector2i) -> Array[Vector2i]:
	# return the pair containing the one
	for offsets in TARGET_OFFSETS:
		if offset in offsets: # ie target in offsets+location
			var nicely_typed_but_otherwise_identical_to_offsets : Array[Vector2i] = Array(offsets, TYPE_VECTOR2I, "", "" )
			return target_with_offsets(nicely_typed_but_otherwise_identical_to_offsets)
	print("SHOULD NOT HAPPEN. _target should be a possible target")
	return []

func die():
	if is_queued_for_deletion():
		return
	
		
	
	await get_tree().create_timer(0.1).timeout
	super()
	
	for offset in [Vector2i(0,0), Vector2i(0,1), Vector2i(1,0), Vector2i(1,1)]:
		var slime = [SLIME_SCENE, RED_SLIME_SCENE].pick_random().instantiate()
		slime.location = location + offset
		slime.position = position + Vector2(offset*world.TILE_SIZE)
		world.units.add_child(slime)
