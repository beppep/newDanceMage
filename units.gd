extends Node
class_name Units

var all_units: Array[Unit] = []
var current_unit_index := 0
var is_running := true
@onready var world = $"/root/World"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if is_instance_valid(child):
			if child.has_method("process_turn"):
				append(child)
			else:
				print_debug("WARNING: ", child.get_class(), " is missing function process_turn()")
	all_units.front().process_turn(world)

func append(unit: Unit):
	all_units.append(unit)
	unit.turn_done.connect(_on_turn_done)

func remove_at(index):
	all_units.remove_at(index)
	# If current unit was last in the list and we removed it
	if current_unit_index == all_units.size():
		current_unit_index = 0
	elif current_unit_index > index:
		current_unit_index = (current_unit_index + all_units.size() - 1) % all_units.size()

func _on_turn_done():
	current_unit_index = (current_unit_index + 1) % all_units.size()
	var unit = all_units[current_unit_index]
	unit.process_turn(world)

func get_unit_at(position: Vector2i):
	for unit in all_units:
		if Vector2i(unit.position) == position:
			return unit
