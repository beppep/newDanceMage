extends Spell


func _ready():
	super()
	life_time = 8

func cast(caster: Unit):
	for x in [-2,-1,0,1,2]:
		for y in [-2,-1,0,1,2]:
			var offset = Vector2i(x,y)
			var target = world.units.get_unit_at(caster.location + offset)
			if target and target!=caster:
				target.frozen += 2
	
	world.particles.make_cloud(caster.location - Vector2i(1,1), "ice", Vector2i(3,3))
