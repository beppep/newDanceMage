extends Node2D
class_name Unit

signal turn_done

@onready var anim = $AnimatedSprite2D

func process_turn(_world: World):
	print("process_turn() not defined for ", name)
	turn_done.emit()
