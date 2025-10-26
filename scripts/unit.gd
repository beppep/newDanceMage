extends Node2D
class_name Unit

signal health_changed

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var world = get_tree().current_scene

var fatness = Vector2i(1,1)
var tween: Tween

var max_health := 1
var health := 1:
	set(val):
		health = val
		if health <= 0:
			die()
			
		health_changed.emit()
		
var speed := 260.0
@onready var location := World.pos_to_loc(position):
	set(loc):
		if is_instance_valid(tween) and tween.is_running():
			await tween.finished
		var new_position = World.loc_to_pos(loc)
		location = loc
		tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "position", new_position, position.distance_to(new_position) / speed)

func process_turn():
	pass

func take_damage(amount=1):
	health -= amount

func is_adjacent_to(to: Vector2i) -> bool:
	return is_in_range_of(to, 1)

func is_in_range_of(to: Vector2i, rang: int) -> bool:
	if to.x>0:
		to.x -= fatness.x-1
	if to.y>0:
		to.y -= fatness.x-1
	return location.distance_squared_to(to) <= rang * rang

func move_to(target: Vector2i):
	if world.is_empty(target, fatness):
		location = target

func move_in_direction(direction: Vector2i, length: int = 1):
	var goal = location
	for i in range(length):
		if not world.is_empty(goal + direction, fatness):
			break
		goal += direction
	location = goal

func die():
	print(name, " died a horrible death.")
	queue_free()
	var p = Particles.new()
	add_child(p)
	p.make_particle_cloud_at(World.loc_to_pos(location), "smoke")
