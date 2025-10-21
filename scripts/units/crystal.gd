extends Unit

@onready var world = $"/root/World"


func die():
	super()
	world.player.unlock_random_spell()


	var p = Particles.new()
	add_child(p)
	p.make_particle_cloud_at(World.loc_to_pos(location), "crystal")
