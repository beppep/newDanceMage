extends Spell


func cast(_player: Unit):
	_player.diamonds += 3
	
	life_time = 8
