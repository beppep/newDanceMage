extends Node2D
class_name Spell

var caster: Node = null
@onready var world = get_tree().current_scene

func _init(_caster):
	caster = _caster


func cast():
	print("cast() is not implemented for ", self)
	pass

func _process(_delta):
	# Automatically free spell when all children are gone
	if get_child_count() == 0:
		queue_free()
