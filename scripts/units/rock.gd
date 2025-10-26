extends Unit

func die():
	super()
	world.particles.make_cloud(location, "rocks")
	
