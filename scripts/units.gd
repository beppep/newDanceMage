extends Node
class_name Units

var is_running := true
@onready var world = $"/root/World"

var SIMULATION_DISTANCE = 10

func _ready() -> void:
	child_exiting_tree.connect(_on_child_exit)

func _on_child_exit(_node: Node):
	for unit in get_units():
		if is_instance_valid(unit) and not unit.is_queued_for_deletion() and unit is Player:
			return
	is_running = false

func start():
	while is_running:
		await _process_turn()
		await get_tree().create_timer(1.0 / 165.0).timeout
	# game over?

func player_take_turns_until_no_more_extra_turns():
	#take player turn
	await world.player.process_turn_unless_frozen()
	# do all of your extra player turns unless you won the level
	while world.player.extra_turn > 0 and not world.ground_tilemap.get_cell_source_id(world.player.location)==4:
		world.player.extra_turn -=1
		await world.player.process_turn_unless_frozen()
		
func _process_turn():
	
	await player_take_turns_until_no_more_extra_turns()
	# next floor check (should this be here?)
	if world.ground_tilemap.get_cell_source_id(world.player.location)==4:
		world.next_floor()
		await player_take_turns_until_no_more_extra_turns() # extra turn on new floor
	
	
	var bombs_first: Array[Unit] = []
	var moves_first: Array[Unit] = []
	var moves_second: Array[Unit] = []
	for unit in get_units():
		if unit is Bomb:
			bombs_first.append(unit)
		elif (unit is Enemy and unit.attack_offsets.is_empty()):
			moves_second.append(unit)
		elif not unit is Player:
			moves_first.append(unit)
	#moves_first.erase(world.player)
	await process_units(bombs_first)
	await process_units(moves_first)
	await process_units(moves_second)

func process_units(units: Array[Unit]):
	for unit in units:
		if not is_instance_valid(unit) or unit.is_queued_for_deletion() or Vector2(unit.location - world.player.location).length() > SIMULATION_DISTANCE:
			continue
		await unit.process_turn_unless_frozen()

func get_units() -> Array[Unit]:
	var units: Array[Unit] = []
	for child in get_children():
		if child is Unit:
			units.append(child)
	return units

func get_unit_at(location: Vector2i) -> Unit:
	for unit in get_units():
		if is_instance_valid(unit) and not unit.is_queued_for_deletion():
			if location.x >= unit.location.x and location.x < unit.location.x + unit.fatness.x and location.y >= unit.location.y and location.y < unit.location.y + unit.fatness.y:
				return unit
	return null
