extends Enemy

@export var egg_scene: PackedScene = preload("res://scenes/units/Egg.tscn")


var TARGET_OFFSETS: Array[Vector2i] = [
		Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(-1,2),
		Vector2i(0,-1),Vector2i(0,2),
		Vector2i(1,-1),Vector2i(1,2),
		Vector2i(2,-1),Vector2i(2,0),Vector2i(2,1),Vector2i(2,2)
	] #lol


func _ready():
	fatness = Vector2i(2,2)
	max_health = 3
	health = 3
	

func do_move():
	var offset = ALL_DIRECTIONS.pick_random()
	print("move fat")
	if world.is_empty(location + offset, fatness, self):
		print("did move fa")
		location += offset

func get_possible_targets() -> Array[Vector2i]:
	return target_with_offsets(TARGET_OFFSETS)

func get_attack_offsets(_target: Vector2i) -> Array[Vector2i]:
	return target_with_offsets(TARGET_OFFSETS)


func perform_attack_effects():
	world.particles.make_cloud(location, "ectoplasm", fatness)
	
func process_turn():
	if attack_offsets.is_empty() and randf() < 0.2:
		spawn_eggs_around_her()
	else:
		super()

func spawn_eggs_around_her():
	for offset in TARGET_OFFSETS:
		if world.is_empty(location+offset) and randf()<0.2:
			var egg = egg_scene.instantiate()
			egg.global_position = global_position + Vector2(0.5,0.5) * world.TILE_SIZE
			world.get_node("Units").add_child(egg)
			egg.location = location + offset
