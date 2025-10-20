extends Node
class_name Particles

func make_particle_cloud_at(pos: Vector2, particle_name : String):
	var p = GPUParticles2D.new()
	var mat = ParticleProcessMaterial.new()
	p.lifetime = 0.3
	p.one_shot = 1
	p.explosiveness = 0.9
	p.amount = 12
	p.texture = load("res://assets/sprites/particles/" + particle_name + ".png")
	mat.initial_velocity_min = 50
	mat.initial_velocity_max = 70
	mat.gravity = Vector3.ZERO
	mat.direction = Vector3(0, 0, 0) # Note: ParticleProcessMaterial uses Vector3 for direction in 2D too
	mat.spread = 180.0
	# set scale/color ramps if desired:

	p.process_material = mat
	p.one_shot = true
	p.emitting = true
	p.global_position = pos
	get_tree().current_scene.get_node("Particles").add_child(p)
	await get_tree().create_timer(p.lifetime + 0.1).timeout
	p.queue_free()
