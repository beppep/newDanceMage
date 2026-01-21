extends Spell


func cast(_player: Unit):
	_player.diamonds += 3
	world.particles.make_cloud(_player.location, "diamond")
	life_time = 8
	return true
