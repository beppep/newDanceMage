extends Spell

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")

func cast(caster: Unit, world: World):
	var target = world.units.get_unit_at(caster.location + caster.get_facing())
	if target:
		target.take_damage(1)
	queue_free()
