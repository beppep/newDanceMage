extends Node2D
class_name Unit

signal turn_done
signal health_changed

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var max_health := 1
var health := 1:
	set(val):
		health = val
		health_changed.emit()
		
var speed := 260.0
@onready var location := World.pos_to_loc(position)

func _process(delta: float) -> void:
	if health <= 0:
		print(name, " died a horrible death.")
		queue_free()
	var target_position = World.loc_to_pos(location)
	if not position.is_equal_approx(target_position):
		position = position.move_toward(target_position, delta * speed)

func process_turn(_world: World):
	print("process_turn() not defined for ", name)
	turn_done.emit()

func take_damage(amount):
	health -= amount

func is_adjacent_to(to: Vector2i) -> bool:
	return is_in_range_of(to, 1)

func is_in_range_of(to: Vector2i, rang: int) -> bool:
	return location.distance_squared_to(to) <= rang * rang

func move(world: World, direction: Vector2i, length: int = 1):
	for i in range(length):
		if not world.is_empty(location + direction):
			break
		location += direction
