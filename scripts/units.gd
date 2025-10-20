extends Node
class_name Units

var is_running := true
@onready var world = $"/root/World"

func start():
	while is_running:
		await process_turn()

func process_turn():
	var moves_first: Array[Unit] = []
	var moves_second: Array[Unit] = []
	for unit in get_units():
		if unit is Player or (unit is Enemy and not unit.attack_targets.is_empty()):
			moves_first.append(unit)
		else:
			moves_second.append(unit)
	await process_units(moves_first)
	await process_units(moves_second)

func process_units(units: Array[Unit]):
	for unit in units:
		if not is_instance_valid(unit) or unit.is_queued_for_deletion():
			continue
		await unit.process_turn(world)

func get_units() -> Array[Unit]:
	var units: Array[Unit] = []
	for child in get_children():
		if child is Unit:
			units.append(child)
	return units

func get_unit_at(location: Vector2i) -> Unit:
	for unit in get_children():
		if Vector2i(unit.location) == location:
			return unit
	return null
