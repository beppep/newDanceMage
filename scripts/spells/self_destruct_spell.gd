extends Spell


func cast(caster: Unit):
	for x in [-2,-1,0,1,2]:
		for y in [-2,-1,0,1,2]:
			var offset = Vector2i(x,y)
			var target = world.units.get_unit_at(caster.location + offset)
			if target:
				target.take_damage()
	
	world.particles.make_cloud(caster.location - Vector2i(1,1), "fire", Vector2i(3,3))
	life_time = 8
