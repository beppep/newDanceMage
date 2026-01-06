extends Enemy

@export var bomb_scene: PackedScene = preload("res://scenes/units/Bomb.tscn")


#var TARGET_OFFSETS: Array[Vector2i]
var charge = 0

func _ready():
	super()
	max_health = 1
	health = 1
	
	
	

func do_move():
	pass


func process_turn():
	
	if Vector2(world.player.location - location).length() > 6:
		return
	
	charge += 1
	if charge == 1:
		if randf() < 0.5:
			charge = 0
		else:
			anim.play("windup")
	elif charge == 2:
		anim.play("shoot")
		charge = 0
		
		# choose location
		var target_loc = world.player.location
		for i in range(100):
			var player_dist = Vector2(target_loc - world.player.location).length() 
			var self_dist = Vector2(target_loc-location).length()
			if world.is_empty(target_loc) and player_dist <= 3 and self_dist >= 2:
				break
			else:
				target_loc = location + Vector2i(randi_range(-3,3),randi_range(-3,3))
		
		# drop da bomb
		var bomb = bomb_scene.instantiate()
		#rock.position = target_cell*world.TILE_SIZE + Vector2i(0,-100)
		world.units.add_child(bomb)
		bomb.position = World.loc_to_pos(location)
		bomb.location = target_loc + Vector2i(0, -7)
		bomb.location = target_loc
		bomb.is_tnt_barrel = false
		world.particles.make_cloud(location, "smoke")
		world.particles.make_cloud(target_loc, "smoke")


 # pls make these not be madatory
func get_attack_offsets(offset: Vector2i) -> Array[Vector2i]:
	print("mortar.get_attack_offsets SHOULD NOT BE CALLED") 
	return [offset]
func get_possible_targets() -> Array[Vector2i]:
	print("mortar.get_possible_targets SHOULD NOT BE CALLED") 
	return []
