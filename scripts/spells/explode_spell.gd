extends Spell

#func _ready():
#	super()
#	life_time = 8 # this is super forbidden. it cancels the whole gane logic

func cast(caster: Unit):
	world.particles.make_cloud(caster.location, "fire")
	for offset in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
		print(offset, "yp", world.units.get_unit_at(caster.location + offset))
		print("awaiting dmg at")
		await world.deal_damage_at(caster.location + offset)
		print("done dmg at ", offset)
	print("dun expl")
	
	life_time = 8
