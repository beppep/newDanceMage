extends Node2D
class_name Unit

signal health_changed

const FROZEN_SPRITE = preload("res://assets/sprites/particles/front_ice.png")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var world : World = get_tree().current_scene

var fatness = Vector2i(1,1)
var tween: Tween

var max_health := 1
var health := 1:
	set(val):
		health = min(val, max_health)
		if health <= 0:
			die()
			
		health_changed.emit()
		
var frozen_indicator : Sprite2D
var frozen := 0:
	set(val):
		frozen = val
		print(self)
		frozen_indicator.visible = frozen > 0
		queue_redraw()

		
var speed := 260.0
@onready var location := World.pos_to_loc(position):
	set(loc):
		location = loc
		if is_instance_valid(tween) and tween.is_running():
			await tween.finished
		var new_position = World.loc_to_pos(loc)
		tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "position", new_position, 0.1)

func _ready():
	frozen_indicator = Sprite2D.new()
	frozen_indicator.texture = FROZEN_SPRITE
	frozen_indicator.visible = false
	add_child(frozen_indicator)
	frozen_indicator.scale = Vector2(fatness)
	frozen_indicator.z_index = 100  # draws above the unit
	frozen_indicator.position = world.TILE_SIZE * (Vector2(fatness) - Vector2(1,1))*0.5

func process_turn_unless_frozen():
	if frozen>0:
		frozen -= 1
	else:
		await process_turn()
	
func process_turn():
	pass #subclass behaviour

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

func teleport_to(loc: Vector2i):
	if is_instance_valid(tween) and tween.is_running():
		tween.kill()
		tween = null
	position = World.loc_to_pos(loc)
	location = loc

func die():
	print(name, " died a horrible death.")
	queue_free()
	world.particles.make_cloud(location, "smoke")
	world.floor_tilemap.set_cell(location, 2, Vector2i(0,0))
