extends Spell



func cast(caster: Unit):
	caster.max_health += 1
	caster.health += 1
	world.particles.make_cloud(caster.location, "heart")
	life_time = 8
