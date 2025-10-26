extends Enemy

func do_move():
	var offset = CARDINAL_DIRECTIONS.pick_random()
	if world.is_empty(location + offset):
		location += offset

func get_possible_targets() -> Array[Vector2i]:
	return target_with_offsets(CARDINAL_DIRECTIONS)

func perform_attack_effects():
	
	var p = Particles.new()
	add_child(p)
	p.make_particle_cloud_at(World.loc_to_pos(location + attack_offsets[-1]), "smoke")
