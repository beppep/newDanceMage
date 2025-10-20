extends Node2D
class_name Unit

signal health_changed

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var max_health := 1
var health := 1:
	set(val):
		health = val
		if health <= 0:
			die()
			
		health_changed.emit()
		
var speed := 260.0
@onready var location := World.pos_to_loc(position)

func _process(delta: float) -> void:
	var target_position = World.loc_to_pos(location)
	if not position.is_equal_approx(target_position):
		position = position.move_toward(target_position, delta * speed)

func process_turn(_world: World):
	print("process_turn() not defined for ", name)

func take_damage(amount):
	health -= amount

func is_adjacent_to(to: Vector2i) -> bool:
	return is_in_range_of(to, 1)

func is_in_range_of(to: Vector2i, rang: int) -> bool:
	return location.distance_squared_to(to) <= rang * rang

func move_to(world: World, target: Vector2i):
	if world.is_empty(target):
		location = target

func move_in_direction(world: World, direction: Vector2i, length: int = 1):
	for i in range(length):
		if not world.is_empty(location + direction):
			break
		location += direction

func die():
	print(name, " died a horrible death.")
	queue_free()
