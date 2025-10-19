extends Node

@onready var world = $"/root/World"
@onready var ground_tilemap = world.get_node("TileMapLayerGround")
@onready var wall_tilemap = world.get_node("TileMapLayerWalls")


var rock_scene = preload("res://scenes/rock.tscn")

var tile_ids = {"OBSIDIAN":0, "STONE":1, "SAND":2, "WOOD":3} # SKETCHY because it has to align with the tileset at all times


func generate_map():
	_paint_area(wall_tilemap, Vector2i(-2, -2), Vector2i(2, 2), tile_ids["STONE"])
	_paint_area(wall_tilemap, Vector2i(-1, -1), Vector2i(1, 1), -1)
	wall_tilemap.set_cell(Vector2i(2, 0), -1 , Vector2i(0, 0))
	#_create_rock_at(Vector2i(2, 0))
	

func _paint_area(tilemap_layer, from_location: Vector2i, to_location: Vector2i, tile_id: int) -> void:
	for x in range(from_location.x, to_location.x + 1):
		for y in range(from_location.y, to_location.y + 1):
			tilemap_layer.set_cell(Vector2i(x, y), tile_id , Vector2i(0, 0))

func _create_rock_at(location: Vector2i):
	var rock = rock_scene.instantiate()
	world.units.append_unit(rock)
	rock.position = World.loc_to_pos(location)
