extends Spell

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")



func cast():
	var target = world.units.get_unit_at(caster.location + caster.move_history[-1])
	if target:
		target.take_damage(1)
	queue_free()
