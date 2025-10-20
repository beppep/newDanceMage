extends Node
class_name Units

var is_running := true
@onready var world = $"/root/World"

func _ready() -> void:
	child_exiting_tree.connect(_on_child_exit)

func _on_child_exit(_node: Node):
	print("In on child exit")
	for unit in get_units():
		if is_instance_valid(unit) and not unit.is_queued_for_deletion() and unit is Player:
			return
	is_running = false

func start():
	while is_running:
		await process_turn()
		await get_tree().create_timer(1.0 / 165.0).timeout

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
	for unit in get_units():
		if is_instance_valid(unit) and not unit.is_queued_for_deletion() and unit.location == location:
			return unit
	return null
