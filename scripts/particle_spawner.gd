extends Node


func make_cloud(location, particle_name, source_fatness = Vector2i(1,1)):
	for x in range(source_fatness.x):
		for y in range(source_fatness.y):
			var p = Particles.new()
			add_child(p)
			var loc = location + Vector2i(x, y)
			p.make_particle_cloud_at(World.loc_to_pos(loc), particle_name)
