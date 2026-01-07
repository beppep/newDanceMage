extends Node2D
class_name Unit

signal health_changed

const FROZEN_SPRITE = preload("res://assets/sprites/particles/front_ice.png")
const SHIELD_SPRITE = preload("res://assets/sprites/particles/shield.png")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var world : World = get_tree().current_scene

@export var fatness = Vector2i(1,1)
var tween: Tween
var shaking = false
var shield_indicator : Sprite2D
var shield := 0:
	set(val):
		shield = val
		print(self)
		shield_indicator.visible = (val > 0)
		queue_redraw()
var max_health := 1
var health := 1:
	set(val):
		health = min(val, max_health)
		health_changed.emit()
var frozen_indicator : Sprite2D
var frozen := 0:
	set(val):
		frozen = val
		print(self)
		frozen_indicator.visible = (frozen > 0)
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
	
	# create the standard frozen-, and shield-texture-child
	for i in range(2):
		var the_indicator = Sprite2D.new()
		the_indicator.texture = [FROZEN_SPRITE, SHIELD_SPRITE][i]
		the_indicator.visible = false
		add_child(the_indicator)
		the_indicator.scale = Vector2(fatness)
		the_indicator.z_index = 100  # draws above the unit
		the_indicator.position = world.TILE_SIZE * (Vector2(fatness) - Vector2(1,1))*0.5
		if i == 0:
			frozen_indicator = the_indicator
		else:
			shield_indicator = the_indicator

func _process(_delta: float):
	if shaking and not frozen:
		position = World.loc_to_pos(location) + Vector2(randf()-randf(), randf()-randf())*1

func process_turn_unless_frozen():
	if shield > 0:
		pass#shield -= 1
	if frozen>0:
		print(self, " frozen: ",frozen)
		frozen -= 1
	else:
		await process_turn()
	
func process_turn():
	pass #subclass behaviour

func take_damage(amount=1):
	if shield:
		shield = 0
		world.particles.make_cloud(location, "shield")
	else:
		health -= amount
		world.particles.make_cloud(location, "attack_indicator")
	if health <= 0:
		if is_instance_valid(self) and not is_queued_for_deletion():
			print("awaiting die")
			await die()
			print("completed die?")

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

func push_units(pusher_location: Vector2i, direction: Vector2i, knockback: int = 1):
	for t in range(knockback):
		#calculate number of consecutive units in this direction
		var _range = 0
		for i in range(1, 20):
			if world.units.get_unit_at(pusher_location + direction*i) == null:
				_range = i
				break
		# push them (in reverse order)
		for i in range(_range):
			var _dist = _range - i
			var target_cell = pusher_location + direction * _dist
			var unit = world.units.get_unit_at(target_cell)
			if unit:
				unit.move_in_direction(direction)
			else:
				print("THIS SHOULD NOT HAPPEN??")

func move_in_direction(direction: Vector2i, length: int = 1):
	var goal = location
	for i in range(length):
		if not world.is_empty(goal + direction, fatness, self):
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
	print(name, get_script().get_global_name(), " died a horrible death.")
	queue_free()
	print(name, get_script().get_global_name(), " died a horrible death...again")
