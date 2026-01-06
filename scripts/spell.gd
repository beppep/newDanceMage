extends Node2D
class_name Spell

var resource: SpellResource
var recipe: Array[Vector2i]
var life_time : int = 999

@onready var world : World = get_tree().current_scene


func _ready() -> void:
	pass
#	child_exiting_tree.connect(_on_child_exit)

#func _on_child_exit(_node: Node) -> void:
#	# Automatically free spell when all children are gone
#	if get_child_count() == 0:
#		queue_free()

func cast(_caster: Unit): # could use ready for this instead?
	print("cast() is not implemented for ", name)
	pass
	
	
func _physics_process(_delta): # called at 60 fps
	life_time -= 1
	if life_time <=0:
		free()
