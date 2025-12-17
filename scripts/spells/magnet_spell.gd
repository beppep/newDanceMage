extends Spell

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")
@onready var wall_tileset := $"/root/World/TileMapLayerWalls"


var RANGE = 5

func _ready():
	super()
	life_time = 8

func cast(caster: Unit):
	for x in range(-RANGE,RANGE):
		for y in range(-RANGE,RANGE):
			var location = caster.location + Vector2i(x,y)
			if world.floor_tilemap.get_cell_source_id(location)==2:
				world.floor_tilemap.set_cell(location, -1, Vector2i(0, 0))
				caster.coins += 1
