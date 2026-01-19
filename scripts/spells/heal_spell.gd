extends Spell



func cast(caster: Unit):
	caster.max_health += 1
	caster.health = caster.max_health
	world.particles.make_cloud(caster.location, "heart")
	life_time = 8
	return true
