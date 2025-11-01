extends Unit



func die():
	super()
	world.player.create_card_reward()


	var p = Particles.new()
	add_child(p)
	p.make_particle_cloud_at(World.loc_to_pos(location), "crystal")
