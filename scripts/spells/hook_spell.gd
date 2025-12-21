extends Spell

@export var rock_scene: PackedScene = preload("res://scenes/units/Rock.tscn")

			
func cast(caster: Unit):
	var target = world.get_closest_unit(caster.location, caster.get_facing())
	if target:
		target.location = caster.location + caster.get_facing()
		await GlobalTimers.delay_frames(8)
		await target.take_damage()
	
	life_time = 8
	#queue_free()
