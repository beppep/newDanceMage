extends Spell

	
func cast(caster: Unit):
	if caster is Player:
		caster.visual_armadillo_curl()
	var direction : Vector2i = caster.get_facing()
	var new_location = caster.location
	while world.is_empty(new_location + direction):
		new_location += direction
	#caster.location = new_location + direction
	caster.location = new_location
	world.particles.make_cloud(new_location + direction, "smoke")
	await world.deal_damage_at(new_location + direction)

	life_time = 8
