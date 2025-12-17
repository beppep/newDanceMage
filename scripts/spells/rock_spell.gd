extends Spell

@export var rock_scene: PackedScene = preload("res://scenes/units/Rock.tscn")


func _ready():
	super()
	life_time = 8
	
func cast(caster: Unit):
	for direction in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		var target_cell = caster.location + direction
		#if world.units.get_unit_at(target_cell):
		#	world.units.get_unit_at(target_cell).move_in_direction(direction)
		world.deal_damage_at(target_cell)
		if world.is_empty(target_cell):
			world.deal_damage_at(target_cell + direction)
			while world.is_empty(target_cell + direction):
				target_cell += direction
				world.deal_damage_at(target_cell + direction)
				
			# rock
			var rock = rock_scene.instantiate()
			world.units.add_child(rock)
			rock.position = caster.position
			rock.location = target_cell
			
