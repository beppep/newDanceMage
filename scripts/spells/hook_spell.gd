extends Spell


			
func cast(caster: Unit):
	var target = world.get_closest_unit(caster.location, caster.get_facing())
	if target:
		target.location = caster.location + caster.get_facing()
		await GlobalTimers.delay_frames(8)
		await world.deal_damage_at(caster.location + caster.get_facing())
	
	life_time = 8
	#queue_free()
