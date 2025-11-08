extends Spell


func cast(caster: Unit):
	var direction : Vector2i = caster.get_facing()
	var new_location = caster.location
	#if world.units.get_unit_at(target_cell):
	#	world.units.get_unit_at(target_cell).move_in_direction(direction)
	while world.is_empty(new_location + direction):
		new_location += direction
	caster.location = new_location
	world.deal_damage_at(new_location + direction)

	queue_free()
