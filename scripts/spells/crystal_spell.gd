extends Spell

@export var crystal_scene: PackedScene = preload("res://scenes/units/Crystal.tscn")

func _ready():
	super()
	life_time = 8

func cast(caster: Unit):
	var target_cell = caster.location + caster.get_facing()
	if world.is_empty(target_cell):
		while world.is_empty(target_cell + caster.get_facing()):
			target_cell = target_cell + caster.get_facing()
		var crystal = crystal_scene.instantiate()
		#rock.position = target_cell*world.TILE_SIZE + Vector2i(0,-100)
		world.units.add_child(crystal)
		crystal.position = caster.position
		crystal.location = target_cell
		
		world.particles.make_cloud(target_cell, "crystal")
		for offset in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
			await world.deal_damage_at(target_cell + offset, 1, caster)
		return true
	return false
