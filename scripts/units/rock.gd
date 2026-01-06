extends Unit

var is_dying := false

func die():
	
	if is_dying or is_queued_for_deletion(): # prevent infinite loops
		return
	is_dying = true
	
	await get_tree().create_timer(0.1).timeout
	
	world.particles.make_cloud(location, "rocks")
	if world.player.items.get("exploding_rocks", 0):
		print("special exf")
		for offset in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
			#if not world.units.get_unit_at(location + offset) == world.player:
			if world.units.get_unit_at(location + offset) is Enemy:
				await world.deal_damage_at(location + offset)

	super()
