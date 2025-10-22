extends Unit


var age = 0

func _ready() -> void:
	anim.play("age0")
	
func process_turn(_world: World):
	age += 1
	anim.play("age"+str(age))
	if age >= 3:
		die()

func die():
	super()
	
	for offset in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
		world.deal_damage_to(location + offset)
	
	var p = Particles.new()
	add_child(p)
	p.make_particle_cloud_at(World.loc_to_pos(location), "rocks")
	
