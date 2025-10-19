extends Node
class_name Units

var current_unit_index := 0
var is_running := true
@onready var world = $"/root/World"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if is_instance_valid(child):
			if child.has_method("process_turn") and child is Unit:
				child.turn_done.connect(_on_turn_done)
			else:
				print_debug("WARNING: ", child.name, " is missing function process_turn()")

func start():
	get_children().front().process_turn(world)

func append_unit(unit: Unit):
	add_child(unit)
	unit.turn_done.connect(_on_turn_done)

func _on_turn_done():
	current_unit_index = (current_unit_index + 1) % get_child_count()
	var unit = get_children()[current_unit_index]
	unit.process_turn(world)

func get_unit_at(location: Vector2i) -> Unit:
	for unit in get_children():
		if Vector2i(unit.location) == location:
			return unit
	return null
