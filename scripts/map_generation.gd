extends Node

@onready var world := $"/root/World"
@onready var ground_tilemap: TileMapLayer = world.get_node("TileMapLayerGround")
@onready var wall_tilemap: TileMapLayer = world.get_node("TileMapLayerWalls")

var MAPSIZE = 20

var rock_scene = preload("res://scenes/units/Rock.tscn")

var tile_ids = {"OBSIDIAN":0, "STONE":1, "SAND":2, "WOOD":3} # SKETCHY because it has to align with the tileset at all times


func generate_map():
	_paint_area(wall_tilemap, Vector2i(-MAPSIZE-2,-MAPSIZE-2),Vector2i(-MAPSIZE-1,MAPSIZE+2), tile_ids["OBSIDIAN"]) # left wall
	_paint_area(wall_tilemap, Vector2i(-MAPSIZE-2,-MAPSIZE-2),Vector2i(MAPSIZE+2,-MAPSIZE-1), tile_ids["OBSIDIAN"]) # up wall
	_paint_area(wall_tilemap, Vector2i(MAPSIZE+1,-MAPSIZE-2),Vector2i(MAPSIZE+2,MAPSIZE+2), tile_ids["OBSIDIAN"]) # right wall
	_paint_area(wall_tilemap, Vector2i(-MAPSIZE-2,MAPSIZE+1),Vector2i(MAPSIZE+2,MAPSIZE+2), tile_ids["OBSIDIAN"]) # down wall
	
	_paint_area(ground_tilemap, Vector2i(-20,-20),Vector2i(20,20), tile_ids["SAND"]) # sand
	
	_create_room(Vector2i(-2,-2),Vector2i(2,2))
	#wall_tilemap.set_cell(Vector2i(2, 0), -1 , Vector2i(0, 0))
	#_create_rock_at(Vector2i(2, 0))
	for i in range(10):
		var random_room_dims = Vector2i(randi_range(2, 10), randi_range(2, 10))
		var random_room_pos = Vector2i(randi_range(-MAPSIZE, MAPSIZE-random_room_dims.x), randi_range(-MAPSIZE, MAPSIZE-random_room_dims.y))
		_create_room(random_room_pos, random_room_pos + random_room_dims)
			
	

func _paint_area(tilemap_layer: TileMapLayer, from_location: Vector2i, to_location: Vector2i, tile_id: int) -> void:
	for x in range(from_location.x, to_location.x + 1):
		for y in range(from_location.y, to_location.y + 1):
			tilemap_layer.set_cell(Vector2i(x, y), tile_id , Vector2i(0, 0))

func _create_rock_at(location: Vector2i):
	var rock: Unit = rock_scene.instantiate()
	rock.position = World.loc_to_pos(location)
	world.units.add_child(rock)
	
func _create_room(from_location: Vector2i, to_location: Vector2i) -> void:
	_paint_area(ground_tilemap, from_location, to_location, tile_ids["WOOD"])
	_paint_area(wall_tilemap, from_location, to_location, tile_ids["STONE"])
	_paint_area(wall_tilemap, from_location+Vector2i(1,1), to_location+Vector2i(-1,-1), -1)
	#_paint_area(wall_tilemap, from_location, Vector2(from_location.x, to_location.y), tile_ids["STONE"])
	#_paint_area(wall_tilemap, Vector2(from_location.x, to_location.y), to_location, tile_ids["STONE"])
	#_paint_area(wall_tilemap, from_location, Vector2(to_location.x, from_location.y), tile_ids["STONE"])
	#_paint_area(wall_tilemap, Vector2(to_location.x, from_location.y), to_location, tile_ids["STONE"])
	
	# DOORS
	for i in range(randi_range(1,3)):
		if randf() < 0.5:
			var height = [from_location.y, to_location.y].pick_random()
			wall_tilemap.set_cell(Vector2i(randi_range(from_location.x+1,to_location.x-1), height), -1 , Vector2i(0, 0))
		else:
			var side = [from_location.x, to_location.x].pick_random()
			wall_tilemap.set_cell(Vector2i(side, randi_range(from_location.y+1,to_location.y-1)), -1 , Vector2i(0, 0))
