extends Spell

@export var crystal_scene: PackedScene = preload("res://scenes/units/Crystal.tscn")

func cast(caster: Unit):
	var directions = [caster.get_facing()]
	if caster.items.get("four_way_shot", 0):
		directions = [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]
	var _resolved = false
	for direction in directions:
		var target_cell = caster.location + direction
		if world.is_empty(target_cell):
			for i in range(8):
				if world.is_empty(target_cell + direction):
					target_cell = target_cell + direction
			var crystal = crystal_scene.instantiate()
			#rock.position = target_cell*world.TILE_SIZE + Vector2i(0,-100)
			world.units.add_child(crystal)
			crystal.position = caster.position
			crystal.location = target_cell
			
			world.particles.make_cloud(target_cell, "crystal")
			for offset in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
				await world.deal_damage_at(target_cell + offset, 1, caster)
			
			_resolved = true
	
	life_time = 8
	return _resolved
	
