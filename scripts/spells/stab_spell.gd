extends Spell

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")

func cast(caster: Unit):
	var target_pos = caster.location + caster.get_facing()
	var target = world.units.get_unit_at(target_pos)
	if target:
		target.take_damage(1)
		
	world.particles.make_cloud(target_pos, "smoke")
	
	queue_free()
