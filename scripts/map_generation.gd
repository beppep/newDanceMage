extends Node

@onready var world: World = $"/root/World"
@onready var ground_tilemap: TileMapLayer = world.get_node("TileMapLayerGround")
@onready var floor_tilemap: TileMapLayer = world.get_node("TileMapLayerFloor")
@onready var wall_tilemap: TileMapLayer = world.get_node("TileMapLayerWalls")

var MAPSIZE = 16

const SHOPSIZE_X = 5
const SHOPSIZE_Y = 3


var trader_scene = preload("res://scenes/units/Trader.tscn")
var rock_scene = preload("res://scenes/units/Rock.tscn")
var crystal_scene = preload("res://scenes/units/Crystal.tscn")
var egg_scene = preload("res://scenes/units/Egg.tscn")
var all_enemies = [egg_scene,
	preload("res://scenes/units/Troll.tscn"),
	preload("res://scenes/enemies/bishop.tscn"),
	preload("res://scenes/enemies/ghost.tscn"),
	preload("res://scenes/enemies/knight.tscn"),
]

var tile_ids = {"OBSIDIAN":0, "STONE":1, "SAND":2, "WOOD":3 ,"STAIRS":4, "HEART":1, "COIN":2} # SKETCHY because it has to align with the tileset at all times

func generate_shop():
	ground_tilemap.clear()
	floor_tilemap.clear()
	wall_tilemap.clear()
	
	world.player.teleport_to(Vector2i(0, 2))
	
	_paint_area(wall_tilemap, Vector2i(-SHOPSIZE_X-2,-SHOPSIZE_Y-2),Vector2i(-SHOPSIZE_X-1,SHOPSIZE_Y+2), tile_ids["OBSIDIAN"]) # left wall
	_paint_area(wall_tilemap, Vector2i(-SHOPSIZE_X-2,-SHOPSIZE_Y-2),Vector2i(SHOPSIZE_X+2,-SHOPSIZE_Y-1), tile_ids["OBSIDIAN"]) # up wall
	_paint_area(wall_tilemap, Vector2i(SHOPSIZE_X+1,-SHOPSIZE_Y-2),Vector2i(SHOPSIZE_X+2,SHOPSIZE_Y+2), tile_ids["OBSIDIAN"]) # right wall
	_paint_area(wall_tilemap, Vector2i(-SHOPSIZE_X-2,SHOPSIZE_Y+1),Vector2i(SHOPSIZE_X+2,SHOPSIZE_Y+2), tile_ids["OBSIDIAN"]) # down wall
	
	_paint_area(ground_tilemap, Vector2i(-SHOPSIZE_X,-SHOPSIZE_Y),Vector2i(SHOPSIZE_X,SHOPSIZE_Y), tile_ids["SAND"]) # sand

	
	var random_pos = Vector2i(-SHOPSIZE_X, -SHOPSIZE_Y)
	ground_tilemap.set_cell(random_pos, tile_ids["STAIRS"] , Vector2i(0, 0))
	
	_create_unit_at(Vector2i(0, -2), crystal_scene)
	
	_create_unit_at(Vector2i(3, -3), trader_scene)
	

func generate_map():
	ground_tilemap.clear()
	floor_tilemap.clear()
	wall_tilemap.clear()
	
	world.player.teleport_to(Vector2i(0, 2))
	
	var MAPSIZE_X = 1 + world.current_floor
	var MAPSIZE_Y = 2 + world.current_floor
	
	_paint_area(wall_tilemap, Vector2i(-MAPSIZE_X-2,-MAPSIZE_Y-2),Vector2i(-MAPSIZE_X-1,MAPSIZE_Y+2), tile_ids["OBSIDIAN"]) # left wall
	_paint_area(wall_tilemap, Vector2i(-MAPSIZE_X-2,-MAPSIZE_Y-2),Vector2i(MAPSIZE_X+2,-MAPSIZE_Y-1), tile_ids["OBSIDIAN"]) # up wall
	_paint_area(wall_tilemap, Vector2i(MAPSIZE_X+1,-MAPSIZE_Y-2),Vector2i(MAPSIZE_X+2,MAPSIZE_Y+2), tile_ids["OBSIDIAN"]) # right wall
	_paint_area(wall_tilemap, Vector2i(-MAPSIZE_X-2,MAPSIZE_Y+1),Vector2i(MAPSIZE_X+2,MAPSIZE_Y+2), tile_ids["OBSIDIAN"]) # down wall
	
	_paint_area(ground_tilemap, Vector2i(-MAPSIZE_X,-MAPSIZE_Y),Vector2i(MAPSIZE_X,MAPSIZE_Y), tile_ids["SAND"]) # sand
	
	for x in range(2*MAPSIZE_X / 8):
		for y in range(2*MAPSIZE_Y / 8):
			var chunk = Vector2i(-MAPSIZE_X, -MAPSIZE_Y) + Vector2i(x,y)*8
			var random_room_dims = Vector2i(randi_range(2, 6), randi_range(2, 6))
			var random_room_pos = Vector2i(randi_range(1, 8-random_room_dims.x), randi_range(1, 8-random_room_dims.y))
			_create_room(chunk+random_room_pos, chunk+random_room_pos + random_room_dims)
	
	for i in range(0):
		var random_room_pos = Vector2i(randi_range(-MAPSIZE_X+1, MAPSIZE_Y-1), randi_range(-MAPSIZE_X+1, MAPSIZE_Y-1))
		while random_room_pos.length() < MAPSIZE_X*0.7:
			random_room_pos = Vector2i(randi_range(-MAPSIZE_X+1, MAPSIZE_Y-1), randi_range(-MAPSIZE_X+1, MAPSIZE_Y-1))
		_create_spell_room(random_room_pos)
		
	# STARTING ROOM
	#_create_room(Vector2i(-2,-2),Vector2i(2,2))
	#wall_tilemap.set_cell(Vector2i(2, 0), -1 , Vector2i(0, 0))
	#_paint_area(wall_tilemap, Vector2i(1, 0), Vector2i(4, 0), -1)
	#_create_rock_at(Vector2i(2, 0))
	print(world.player.location)
	_paint_area(wall_tilemap, world.player.location + Vector2i(-1, -1), world.player.location + Vector2i(1, 1), -1)
	
	# ROCKS
	var random_pos
	for i in range(MAPSIZE_X^2):
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
		if random_pos.length() > 3:
			if randf()<0.9:
				_create_unit_at(random_pos, rock_scene)
			else:
				floor_tilemap.set_cell(random_pos, tile_ids["COIN"], Vector2i(0, 0))
	
	# ENEMIES
	for i in range(MAPSIZE_X^2):
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
		if random_pos.length() > 3:
			_create_unit_at(random_pos, all_enemies.pick_random())
	
	# EGGS
	if MAPSIZE_X>6:
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
		for i in range(10):
			random_pos = Vector2i(clamp(random_pos.x + randi_range(-2, 2), -MAPSIZE_X, MAPSIZE_X), clamp(random_pos.y + randi_range(-2, 2), -MAPSIZE_Y, MAPSIZE_Y))
			if random_pos.length() > 3:
				_create_unit_at(random_pos, egg_scene)
	
	random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
	while not world.is_empty(random_pos) or Vector2(random_pos).length()<MAPSIZE_Y*0.5:
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
	ground_tilemap.set_cell(random_pos, tile_ids["STAIRS"] , Vector2i(0, 0))

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
