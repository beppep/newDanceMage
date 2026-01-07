extends Spell


var RANGE = 10

func _ready():
	super()
	life_time = 8

func cast(caster: Unit):
	world.particles.make_cloud(caster.location, "ectoplasm")
	var test_loc = caster.location
	for i in range(100):
		var direction = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, caster.get_facing()].pick_random()
		if not world.is_wall_at(test_loc + direction):
			test_loc += direction
		if world.is_empty(test_loc) and Vector2(test_loc - caster.location).length()>(10-i/9):#terminates
			break
	caster.location = test_loc
	world.particles.make_cloud(caster.location, "ectoplasm")
				
