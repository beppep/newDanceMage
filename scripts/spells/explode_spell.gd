extends Spell

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")

func cast(caster: Unit):
	for offset in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
		world.deal_damage_to(caster.location + offset)
	
	var p = Particles.new()
	add_child(p)
	p.make_particle_cloud_at(World.loc_to_pos(caster.location), "fire")
