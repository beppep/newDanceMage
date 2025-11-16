extends Spell

func _ready():
	super()
	life_time = 8

func cast(caster: Unit):
	for offset in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
		world.deal_damage_at(caster.location + offset)
	
	world.particles.make_cloud(caster.location, "fire")
