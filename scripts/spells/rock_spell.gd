extends Spell

@export var rock_scene: PackedScene = preload("res://scenes/units/Rock.tscn")


			
func cast(caster: Unit):
	var target_cell = caster.location + caster.get_facing()
	while not world.is_wall_at(target_cell):
		await world.deal_damage_at(target_cell)
		await get_tree().process_frame
		if world.is_empty(target_cell):
			# rock
			var rock = rock_scene.instantiate()
			world.units.add_child(rock)
			rock.position = caster.position
			rock.location = target_cell
		target_cell += caster.get_facing()
	
	queue_free()
