extends Node2D
class_name Unit

signal turn_done

@onready var anim = $AnimatedSprite2D

var speed := 200.0
var location := Vector2i(position / World.TILE_SIZE)

func _process(delta: float) -> void:
	var target_position = location * World.TILE_SIZE + Vector2i(floori(World.TILE_SIZE / 2.0), floori(World.TILE_SIZE / 2.0))
	if not position.is_equal_approx(target_position):
		position = position.move_toward(target_position, delta * speed)

func process_turn(_world: World):
	print("process_turn() not defined for ", name)
	turn_done.emit()
