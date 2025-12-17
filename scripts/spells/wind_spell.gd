extends Spell

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")
@onready var wall_tileset := $"/root/World/TileMapLayerWalls"


var RANGE = 10

func _ready():
	super()
	life_time = 8

func cast(caster: Unit):
	for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		# push in reverse order
		for i in range(RANGE):
			var j = RANGE - i
			var target_cell = caster.location + Vector2i(direction * j)
			var unit = world.units.get_unit_at(target_cell)
			if unit:
				unit.move_in_direction(direction)
