extends Unit

var is_dying := false

func die():
	
	if is_dying or is_queued_for_deletion(): # prevent infinite loops
		return
	is_dying = true
	
	await get_tree().create_timer(0.1).timeout
	
	
	world.particles.make_cloud(location, "rocks")
	
	super()
	
