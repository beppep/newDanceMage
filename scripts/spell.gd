extends Node2D
class_name Spell

var resource: SpellResource
var caster: Node
@onready var world = get_tree().current_scene
var recipe: Array[Vector2i]

func _init(_caster):
	caster = _caster

func _ready() -> void:
	child_exiting_tree.connect(_on_child_exit)

func _on_child_exit(_node: Node) -> void:
	# Automatically free spell when all children are gone
	if get_child_count() == 0:
		queue_free()

func cast():
	print("cast() is not implemented for ", name)
	pass
