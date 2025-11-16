extends Spell

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")
@onready var wall_tileset := $"/root/World/TileMapLayerWalls"


var anim_timer = 8
var RANGE = 5

func cast(caster: Unit):
	for x in range(-RANGE,RANGE):
		for y in range(-RANGE,RANGE):
			var location = caster.location + Vector2i(x,y)
			if world.floor_tilemap.get_cell_source_id(location)==2:
				world.floor_tilemap.set_cell(location, -1, Vector2i(0, 0))
				caster.coins += 1

func _physics_process(_delta): # called at 60 fps
	anim_timer -= 1
	if anim_timer <=0:
		queue_free()
