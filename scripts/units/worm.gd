extends Enemy
class_name Worm

@export var worm_scene: PackedScene = preload("res://scenes/units/Worm.tscn")

var front: Worm = null
var tail : Worm = null

func _ready():
	print("h")
	if front==null or randf() < 0.8:
		print("hw")
		tail = worm_scene.instantiate()
		var direction = Vector2i(Vector2.RIGHT.rotated(anim.rotation))
		#tail.anim.rotation = anim.rotation
		tail.position = position - Vector2(direction*16)
		tail.location = location - direction
		tail.front = self
		
		get_parent().add_child.call_deferred(tail)
		
		if front==null:
			anim.play("head")
		else:
			anim.play("body")
	else:
		anim.play("tail")

func do_move(world: World):
	if front==null:
		crawl_in_dir(CARDINAL_DIRECTIONS.pick_random())

func crawl_in_dir(offset):
	if world.is_empty(location + offset):
		tail.follow_worm_front()
		location += offset
		
		var new_rotation = Vector2(offset).angle()
		if new_rotation == anim.rotation:
			tail.anim.play("body")
		else:
			tail.anim.play("turn")
			tail.anim.flip_v = (wrapf(anim.rotation - new_rotation, -PI, PI)>0)
		tail.anim.rotation = new_rotation
		anim.rotation = new_rotation
			

func follow_worm_front():
	if tail:
		tail.follow_worm_front()
		if tail.tail:
			tail.anim.play(anim.animation)
			tail.anim.flip_v = anim.flip_v
	else:
		anim.play("tail")
	anim.rotation = front.anim.rotation
	anim.flip_v = front.anim.flip_v
	location = front.location

func get_possible_targets(world: World) -> Array[Vector2i]:
	if front == null:
		return target_with_offsets(world, CARDINAL_DIRECTIONS)
	else:
		return []

func perform_attack_effects(_world: World):
	if front==null:
		crawl_in_dir(attack_offsets.front())
			
func process_turn(world: World):
	if front == null: # means youre the head
		super(world)
	elif not is_instance_valid(front): # head died
		front = null
		anim.play("head")
		print("hi im head now")
	elif not is_instance_valid(front):
		anim.play("tail")
	else: # youre the body
		pass
