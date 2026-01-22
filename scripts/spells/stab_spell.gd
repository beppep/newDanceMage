extends Spell


func cast(caster: Unit):
	var target_pos = caster.location + caster.get_facing()
	var target = world.units.get_unit_at(target_pos)

	var offset = Vector2(caster.get_facing()) * 8.0
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(caster, "position", offset, 0.06).as_relative()
	tween.tween_property(caster, "position", -offset, 0.06).as_relative()

	var camera_tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	camera_tween.tween_property(caster.get_node('Camera2D'), "position", -offset, 0.06).as_relative()
	camera_tween.tween_property(caster.get_node('Camera2D'), "position", offset, 0.06).as_relative()

	if target:
		await target.take_damage(1)
	
	life_time = 8
