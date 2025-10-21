extends Node

@onready var world := $"/root/World"
@onready var ground_tilemap: TileMapLayer = world.get_node("TileMapLayerGround")
@onready var wall_tilemap: TileMapLayer = world.get_node("TileMapLayerWalls")

var MAPSIZE = 20

var rock_scene = preload("res://scenes/units/Rock.tscn")
var crystal_scene = preload("res://scenes/units/Crystal.tscn")
var egg_scene = preload("res://scenes/units/Egg.tscn")

var tile_ids = {"OBSIDIAN":0, "STONE":1, "SAND":2, "WOOD":3} # SKETCHY because it has to align with the tileset at all times


func generate_map():
	_paint_area(wall_tilemap, Vector2i(-MAPSIZE-2,-MAPSIZE-2),Vector2i(-MAPSIZE-1,MAPSIZE+2), tile_ids["OBSIDIAN"]) # left wall
	_paint_area(wall_tilemap, Vector2i(-MAPSIZE-2,-MAPSIZE-2),Vector2i(MAPSIZE+2,-MAPSIZE-1), tile_ids["OBSIDIAN"]) # up wall
	_paint_area(wall_tilemap, Vector2i(MAPSIZE+1,-MAPSIZE-2),Vector2i(MAPSIZE+2,MAPSIZE+2), tile_ids["OBSIDIAN"]) # right wall
	_paint_area(wall_tilemap, Vector2i(-MAPSIZE-2,MAPSIZE+1),Vector2i(MAPSIZE+2,MAPSIZE+2), tile_ids["OBSIDIAN"]) # down wall
	
	_paint_area(ground_tilemap, Vector2i(-20,-20),Vector2i(20,20), tile_ids["SAND"]) # sand
	
	for x in range(2*MAPSIZE / 10):
		for y in range(2*MAPSIZE / 10):
			var chunk = Vector2i(-MAPSIZE, -MAPSIZE) + Vector2i(x,y)*10
			var random_room_dims = Vector2i(randi_range(2, 10), randi_range(2, 10))
			var random_room_pos = Vector2i(randi_range(0, 10-random_room_dims.x), randi_range(0, 10-random_room_dims.y))
			_create_room(chunk+random_room_pos, chunk+random_room_pos + random_room_dims)
	
	for i in range(6):
		var random_room_pos = Vector2i(randi_range(-MAPSIZE+1, MAPSIZE-1), randi_range(-MAPSIZE+1, MAPSIZE-1))
		while random_room_pos.length() < 10:
			random_room_pos = Vector2i(randi_range(-MAPSIZE+1, MAPSIZE-1), randi_range(-MAPSIZE+1, MAPSIZE-1))
		_create_spell_room(random_room_pos)
		
	_create_room(Vector2i(-2,-2),Vector2i(2,2))
	#wall_tilemap.set_cell(Vector2i(2, 0), -1 , Vector2i(0, 0))
	#_create_rock_at(Vector2i(2, 0))
	
	# ROCKS
	var random_pos
	for i in range(10):
		random_pos = Vector2i(randi_range(-MAPSIZE, MAPSIZE), randi_range(-MAPSIZE, MAPSIZE))
		if random_pos.length() > 3:
			_create_unit_at(random_pos, rock_scene)
	
	# EGGS
	random_pos = Vector2i(randi_range(-MAPSIZE, MAPSIZE), randi_range(-MAPSIZE, MAPSIZE))
	for i in range(10):
		random_pos = Vector2i(clamp(random_pos.x + randi_range(-3, 3), -MAPSIZE, MAPSIZE), clamp(random_pos.y + randi_range(-3, 3), -MAPSIZE, MAPSIZE))
		if random_pos.length() > 3:
			_create_unit_at(random_pos, egg_scene)

func _paint_area(tilemap_layer: TileMapLayer, from_location: Vector2i, to_location: Vector2i, tile_id: int) -> void:
	var min_vec = Vector2(min(from_location.x, to_location.x), min(from_location.y, to_location.y))
	var max_vec = Vector2(max(from_location.x, to_location.x), max(from_location.y, to_location.y))
	for x in range(min_vec.x, max_vec.x + 1):
		for y in range(min_vec.y, max_vec.y + 1):
			tilemap_layer.set_cell(Vector2i(x, y), tile_id , Vector2i(0, 0))

func _create_unit_at(location: Vector2i, scene : PackedScene):
	if world.is_empty(location):
		var thing: Unit = scene.instantiate()
		thing.position = World.loc_to_pos(location)
		world.units.add_child(thing)
		return true
	return false

func _create_spell_room(center_loc: Vector2i) -> void:
	_paint_area(ground_tilemap, center_loc-Vector2i(2,2), center_loc+Vector2i(2,2), tile_ids["WOOD"])
	_paint_area(wall_tilemap, center_loc-Vector2i(2,2), center_loc+Vector2i(2,2), tile_ids["OBSIDIAN"])
	_paint_area(wall_tilemap, center_loc-Vector2i(1,1), center_loc+Vector2i(1,1), -1)
	
	#doorway
	var door = [Vector2i.RIGHT,Vector2i.UP,Vector2i.LEFT,Vector2i.DOWN].pick_random()*2
	wall_tilemap.set_cell(center_loc+door, -1 , Vector2i(0, 0))
	_paint_area(wall_tilemap, center_loc, center_loc+door*2, -1)
	_create_unit_at(center_loc+door, rock_scene)
	_create_unit_at(center_loc, crystal_scene)
	
	
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
