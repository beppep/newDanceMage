extends Node
class_name MapGenerator

@onready var world: World = $"/root/World"
@onready var ground_tilemap: TileMapLayer = world.get_node("Level/TileMapLayerGround")
@onready var floor_tilemap: TileMapLayer = world.get_node("Level/TileMapLayerFloor")
@onready var wall_tilemap: TileMapLayer = world.get_node("Level/TileMapLayerWalls")

var MAPSIZE = 16

const SHOPSIZE_X = 5
const SHOPSIZE_Y = 3

#const CHEAT = true

var boss_scene = preload("res://scenes/enemies/boss3x3.tscn")
var troll_scene = preload("res://scenes/units/Troll.tscn")
var knight_scene = preload("res://scenes/enemies/knight.tscn")
var bishop_scene = preload("res://scenes/enemies/bishop.tscn")
var rook_scene = preload("res://scenes/enemies/rook.tscn")
var pawn_scene = preload("res://scenes/enemies/pawn.tscn")
var ghost_scene = preload("res://scenes/enemies/ghost.tscn")
var skeleton_archer_scene = preload("res://scenes/units/Skeleton_archer.tscn")
var mother_ghost_scene = preload("res://scenes/enemies/mother_ghost.tscn")
var egg_scene = preload("res://scenes/units/Egg.tscn")
var rock_scene = preload("res://scenes/units/Rock.tscn")

var crystal_scene = preload("res://scenes/units/Crystal.tscn")
var chest_scene = preload("res://scenes/units/Chest.tscn")

var trader_scene = preload("res://scenes/units/Trader.tscn")

var CHESS_ENEMIES = [
	{"level": 1, "scene": pawn_scene},
	{"level": 3, "scene": bishop_scene},
	{"level": 3, "scene": knight_scene},
	{"level": 5, "scene": rook_scene},
	
]

var CAVE_ENEMIES := [
	{"level": 1, "scene": preload("res://scenes/units/Slime.tscn")},
	{"level": 1, "scene": troll_scene},
	{"level": 1, "scene": preload("res://scenes/units/Bomb.tscn")},
	{"level": 2, "scene": egg_scene},
	{"level": 2, "scene": preload("res://scenes/enemies/ghost.tscn")},
	{"level": 3, "scene": preload("res://scenes/units/RedSlime.tscn")},
	{"level": 3, "scene": preload("res://scenes/units/mother_slime.tscn"), "fatness":Vector2i(2,2)},
	{"level": 3, "scene": skeleton_archer_scene},
	{"level": 6, "scene": preload("res://scenes/enemies/mortar.tscn")},
	{"level": 7, "scene": mother_ghost_scene, "fatness":Vector2i(2,2)},
	{"level": 8, "scene": preload("res://scenes/units/Worm.tscn")},
]

var tile_ids = Globals.tile_ids



func generate_map():
	world.pentagram_location = null
	world.all_spike_locations = []
	ground_tilemap.clear()
	floor_tilemap.clear()
	wall_tilemap.clear()
	if world.current_floor == 9:
		generate_final_boss_room()
	elif world.current_floor == 4 or world.current_floor == 7:
		if randf() < 0.5:
			generate_boss_room()
		else:
			generate_chessboard()
	else:
		if world.current_floor == 2 or randf() < 0.7:
			generate_map_cavestyle()
		else:
			generate_map_chess_style()




func generate_shop(first_floor=false): # old and unused
	
	world.player.teleport_to(Vector2i(0, 2))
	
	_create_borders(-SHOPSIZE_X, SHOPSIZE_X, -SHOPSIZE_Y, SHOPSIZE_Y)
	
	_paint_area(ground_tilemap, Vector2i(-SHOPSIZE_X,-SHOPSIZE_Y),Vector2i(SHOPSIZE_X,SHOPSIZE_Y), tile_ids["WOOD"]) # sand

	
	var random_pos = Vector2i(-SHOPSIZE_X, -SHOPSIZE_Y)
	ground_tilemap.set_cell(random_pos, tile_ids["STAIRS"] , Vector2i(0, 0))
	
	if not first_floor:
		_create_unit_at(Vector2i(0, -2), crystal_scene)
	
		_create_unit_at(Vector2i(3, -3), trader_scene)
	
	#if first_floor and CHEAT:
	#	_create_unit_at(Vector2i(1, -2), crystal_scene)
	#	_create_unit_at(Vector2i(2, -2), crystal_scene)
	#	_create_unit_at(Vector2i(0, -2), crystal_scene)

func generate_chessboard():
	
	world.player.teleport_to(Vector2i(3, 6))
	
	
	_create_borders(0, 7, 0, 7)
	_paint_area(ground_tilemap, Vector2i(0,0),Vector2i(7,7), tile_ids["WHITE"]) # sand
	for x in range(8):
		for y in range(8):
			if (x+y)%2 == 1:
				ground_tilemap.set_cell(Vector2i(x,y), tile_ids["BLACK"], Vector2i(0,0))
	
	_create_unit_at(Vector2i(0,0), rook_scene)
	_create_unit_at(Vector2i(1,0), knight_scene)
	_create_unit_at(Vector2i(2,0), bishop_scene)
	_create_unit_at(Vector2i(3,0), rook_scene)
	_create_unit_at(Vector2i(4,0), chest_scene)
	_create_unit_at(Vector2i(5,0), bishop_scene)
	_create_unit_at(Vector2i(6,0), knight_scene)
	_create_unit_at(Vector2i(7,0), rook_scene)
	for x in range(8):
		var pwn = _create_unit_at(Vector2i(x,1), pawn_scene)
		pwn.pawn_direction = Vector2i.DOWN
		
	ground_tilemap.set_cell(Vector2i(4,0), tile_ids["STAIRS"] , Vector2i(0, 0))

func generate_boss_room():
	
	const ARENA_SIZE = 3
	
	_paint_area(ground_tilemap, Vector2i(-ARENA_SIZE,-ARENA_SIZE),Vector2i(ARENA_SIZE,ARENA_SIZE), tile_ids["SAND"])
	_paint_area(wall_tilemap, Vector2i(-ARENA_SIZE,-ARENA_SIZE),Vector2i(ARENA_SIZE,ARENA_SIZE), -1)
	_create_borders(-ARENA_SIZE, ARENA_SIZE, -ARENA_SIZE, ARENA_SIZE)
	
	_create_unit_at(Vector2i(randi_range(-1,0), randi_range(-1,0)), mother_ghost_scene)
	
	ground_tilemap.set_cell(Vector2i(0, 0), tile_ids["STAIRS"] , Vector2i(0, 0)) # exit
	
	var PLAYER_SPAWN = Vector2i(randi_range(-ARENA_SIZE,ARENA_SIZE), randi_range(-1,1)*ARENA_SIZE)
	world.player.teleport_to(PLAYER_SPAWN)
	
	_create_unit_at(Vector2i(randi_range(-ARENA_SIZE, ARENA_SIZE), -ARENA_SIZE), chest_scene)
	
	# EGGS
	var random_pos = Vector2i(randi_range(-ARENA_SIZE, ARENA_SIZE), randi_range(-ARENA_SIZE, ARENA_SIZE))
	for i in range(20):
		random_pos = Vector2i(randi_range(-ARENA_SIZE, ARENA_SIZE), randi_range(-ARENA_SIZE, ARENA_SIZE))
		_create_unit_at(random_pos, egg_scene)

func generate_final_boss_room():
	
	const ARENA_SIZE = 4
	
	_paint_area(ground_tilemap, Vector2i(-ARENA_SIZE,-ARENA_SIZE),Vector2i(ARENA_SIZE,ARENA_SIZE), tile_ids["SAND"])
	#_paint_area(wall_tilemap, Vector2i(-ARENA_SIZE,-ARENA_SIZE),Vector2i(ARENA_SIZE,ARENA_SIZE), -1)
	_create_borders(-ARENA_SIZE, ARENA_SIZE, -ARENA_SIZE, ARENA_SIZE)
	
	var end_loc= Vector2i(randi_range(-ARENA_SIZE,ARENA_SIZE), -ARENA_SIZE-1)
	ground_tilemap.set_cell(end_loc, tile_ids["STAIRS"], Vector2i(0, 0)) # exit
	wall_tilemap.set_cell(end_loc, -1, Vector2i(0, 0)) # exit air
	
	var PLAYER_SPAWN = Vector2i(0, ARENA_SIZE)
	world.player.teleport_to(PLAYER_SPAWN)
	
	#for x in range(-ARENA_SIZE, ARENA_SIZE+1):
	#	_create_unit_at(Vector2i(x, -ARENA_SIZE), skeleton_archer_scene)
	
	_create_unit_at(Vector2i(1, -1), boss_scene)
	_create_unit_at(Vector2i(-3, -1), boss_scene)
	
	# ROCKS
	for i in range(20):
		var random_loc = Vector2i(randi_range(-ARENA_SIZE, ARENA_SIZE), randi_range(-ARENA_SIZE, ARENA_SIZE))
		_create_unit_at(random_loc, rock_scene)
	
	for y in range(-ARENA_SIZE, ARENA_SIZE+1):
		var loc = Vector2i([-1,1].pick_random()*ARENA_SIZE, y)
		var tile_id = [tile_ids["SPIKES"], tile_ids["NOSPIKES"], tile_ids["GRAVE"], tile_ids["SAND"]].pick_random()
		ground_tilemap.set_cell(loc, tile_id, Vector2i(0, 0))
		if tile_id == tile_ids["GRAVE"]:
			world.grave_locations = loc
		
		
	world.all_spike_locations = []
	for x in range(-ARENA_SIZE, ARENA_SIZE+1):
		for y in range(-ARENA_SIZE, ARENA_SIZE+1):
			var cell = ground_tilemap.get_cell_source_id(Vector2i(x,y))
			if cell in [tile_ids["SPIKES"], tile_ids["NOSPIKES"]]:
				world.all_spike_locations.append(Vector2i(x,y))

func generate_map_cavestyle():
	
	
	var MAPSIZE_X = 5 + floor(world.current_floor*0.4) # mapsize depends on current floor
	var MAPSIZE_Y = 5 + floor(world.current_floor*0.4) # mapsize then decides things for worldgen (like amount of stuff)

	_create_borders(-MAPSIZE_X, MAPSIZE_X, -MAPSIZE_Y, MAPSIZE_Y)

	var PLAYER_SPAWN = Vector2i(randi_range(-MAPSIZE_X,MAPSIZE_X),randi_range(-MAPSIZE_Y, MAPSIZE_Y))
	world.player.teleport_to(PLAYER_SPAWN)
	
	_paint_area(ground_tilemap, Vector2i(-MAPSIZE_X,-MAPSIZE_Y),Vector2i(MAPSIZE_X,MAPSIZE_Y), tile_ids["SAND"])
	_paint_area(wall_tilemap, Vector2i(-MAPSIZE_X,-MAPSIZE_Y),Vector2i(MAPSIZE_X,MAPSIZE_Y), tile_ids["STONE"])
	
	
	# RANDOM WALK CAVE: PLAYER -> EXIT
	var cave_volume = 0 # unsure about the volume requirement.
	var randomwalk_loc = PLAYER_SPAWN
	var prev_step = Vector2i.ZERO
	while cave_volume < MAPSIZE_X * MAPSIZE_Y or Vector2(randomwalk_loc).length() < MAPSIZE_X or Vector2(randomwalk_loc-PLAYER_SPAWN).length() < MAPSIZE_X: # air density is about a quarter?
		if not world.is_empty(randomwalk_loc):
			cave_volume += 1
			_paint_area(wall_tilemap, randomwalk_loc, randomwalk_loc+Vector2i(0,0), -1)
			await get_tree().process_frame # cool af
		prev_step = _take_random_walk_step(randomwalk_loc, prev_step, MAPSIZE_X, MAPSIZE_Y)
		randomwalk_loc += prev_step
	_paint_area(wall_tilemap, randomwalk_loc, randomwalk_loc+Vector2i(0,0), -1)
	ground_tilemap.set_cell(randomwalk_loc, tile_ids["STAIRS"] , Vector2i(0, 0)) # exit
	print("placed stairs with edgyness: ", Vector2(randomwalk_loc).length(), " distance: ",Vector2(randomwalk_loc-PLAYER_SPAWN).length(), " and volume: ", cave_volume)
	
	
	# RANDOM WALK: SPELL CRYSTAL -> AIR
	randomwalk_loc = _find_wall(MAPSIZE_X, MAPSIZE_Y)
	randomwalk_to_air(randomwalk_loc, MAPSIZE_X, MAPSIZE_Y)
	_paint_area(wall_tilemap, randomwalk_loc+Vector2i(-1,-1), randomwalk_loc+Vector2i(1,1), -1)
	_create_unit_at(randomwalk_loc, crystal_scene) # after putting air
		
	# RANDOM WALK: SHOP -> AIR
	randomwalk_loc = _find_wall(MAPSIZE_X, MAPSIZE_Y)
	randomwalk_to_air(randomwalk_loc, MAPSIZE_X, MAPSIZE_Y)
	_paint_area(ground_tilemap, randomwalk_loc+Vector2i(-1,0), randomwalk_loc+Vector2i(1,1), tile_ids["WOOD"])
	_paint_area(wall_tilemap, randomwalk_loc+Vector2i(-1,0), randomwalk_loc+Vector2i(1,1), -1)
	_create_unit_at(randomwalk_loc, trader_scene) # after putting air
	
	# RANDOM WALK: CHEST -> AIR
	randomwalk_loc = _find_wall(MAPSIZE_X, MAPSIZE_Y)
	randomwalk_to_air(randomwalk_loc, MAPSIZE_X, MAPSIZE_Y)
	_paint_area(wall_tilemap, randomwalk_loc+Vector2i(-1,-1), randomwalk_loc+Vector2i(1,1), -1)
	if randf()<0.5:
		for offset in [Vector2i(0,1), Vector2i(1,1), Vector2i(1,0), Vector2i(1,-1), Vector2i(0,-1), Vector2i(-1,-1), Vector2i(-1,0), Vector2i(-1,1)]:
			ground_tilemap.set_cell(randomwalk_loc+offset, [tile_ids["SPIKES"], tile_ids["NOSPIKES"], tile_ids["SAND"]].pick_random(), Vector2i(0, 0))
	_create_unit_at(randomwalk_loc, chest_scene)
	
	if randf() < 0.5:
		# RANDOM WALK: PENTAGRAM -> AIR
		randomwalk_loc = _find_wall(MAPSIZE_X, MAPSIZE_Y)
		if randomwalk_loc.y != -MAPSIZE_Y: # (want space above)
			randomwalk_to_air(randomwalk_loc, MAPSIZE_X, MAPSIZE_Y)
			ground_tilemap.set_cell(randomwalk_loc, tile_ids["PENTAGRAM"], Vector2i(0, 0))
			wall_tilemap.set_cell(randomwalk_loc, -1, Vector2i(0, 0))
			wall_tilemap.set_cell(randomwalk_loc+Vector2i(0, -1), -1, Vector2i(0, 0))
			world.pentagram_location = randomwalk_loc
	
	# ENEMIES
	var random_pos #loc
	for i in range(MAPSIZE_X**2):
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
		if (random_pos-PLAYER_SPAWN).length() > 1:
			_create_random_unit_at(random_pos, CAVE_ENEMIES)
	
	# ROCKS
	for i in range(2*MAPSIZE_X**2):
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
		if (random_pos-PLAYER_SPAWN).length() > 1:
			_create_unit_at(random_pos, rock_scene)
	
	# EGGS
	if MAPSIZE_X>6:
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
		for i in range(10):
			random_pos = Vector2i(clamp(random_pos.x + randi_range(-2, 2), -MAPSIZE_X, MAPSIZE_X), clamp(random_pos.y + randi_range(-2, 2), -MAPSIZE_Y, MAPSIZE_Y))
			if random_pos.length() > 3:
				_create_unit_at(random_pos, egg_scene)
	
	if world.current_floor > 2:
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
		ground_tilemap.set_cell(random_pos, tile_ids["GRAVE"], Vector2i(0, 0))
		world.grave_locations = random_pos
	else:
		world.grave_locations = null
	
	world.all_spike_locations = []
	for x in range(-MAPSIZE_X, MAPSIZE_X+1):
		for y in range(-MAPSIZE_Y, MAPSIZE_Y+1):
			var cell = ground_tilemap.get_cell_source_id(Vector2i(x,y))
			if cell in [tile_ids["SPIKES"], tile_ids["NOSPIKES"]]:
				world.all_spike_locations.append(Vector2i(x,y))

func generate_map_chess_style():
	
	var PLAYER_SPAWN = Vector2i(0,0)
	world.player.teleport_to(PLAYER_SPAWN)
	
	var MAPSIZE_X = 4 + world.current_floor/2
	var MAPSIZE_Y = 4 + world.current_floor/2
	
	_create_borders(-MAPSIZE_X, MAPSIZE_X, -MAPSIZE_Y, MAPSIZE_Y)
	
	for x in range(-MAPSIZE_X, MAPSIZE_X+1):
		for y in range(-MAPSIZE_Y, MAPSIZE_Y+1):
			if posmod((x+y),2) == 1: # godot % moment
				ground_tilemap.set_cell(Vector2i(x,y), tile_ids["BLACK"], Vector2i(0,0))
			else:
				ground_tilemap.set_cell(Vector2i(x,y), tile_ids["WHITE"], Vector2i(0,0))
				
	for x in range(2*MAPSIZE_X / 8):
		for y in range(2*MAPSIZE_Y / 8):
			var chunk = Vector2i(-MAPSIZE_X, -MAPSIZE_Y) + Vector2i(x,y)*8
			var random_room_dims = Vector2i(randi_range(2, 6), randi_range(2, 6))
			var random_room_pos = Vector2i(randi_range(1, 8-random_room_dims.x), randi_range(1, 8-random_room_dims.y))
			_create_room(chunk+random_room_pos, chunk+random_room_pos + random_room_dims)
	
	for i in range(1):
		var random_room_pos = Vector2i(randi_range(-MAPSIZE_X+1, MAPSIZE_Y-1), randi_range(-MAPSIZE_X+1, MAPSIZE_Y-1))
		while random_room_pos.length() < MAPSIZE_X*0.7:
			random_room_pos = Vector2i(randi_range(-MAPSIZE_X+1, MAPSIZE_Y-1), randi_range(-MAPSIZE_X+1, MAPSIZE_Y-1))
		_create_spell_room(random_room_pos)
		
	print(world.player.location)
	_paint_area(wall_tilemap, world.player.location + Vector2i(-1, -1), world.player.location + Vector2i(1, 1), -1)
	
	# ROCKS
	var random_pos
	for i in range(MAPSIZE_X):
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
		if (random_pos-PLAYER_SPAWN).length() > 1:
			_create_unit_at(random_pos, rock_scene)
	
	# ENEMIES
	for i in range(MAPSIZE_X + world.current_floor**2):
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, MAPSIZE_Y))
		if (random_pos-PLAYER_SPAWN).length() > 2:
			_create_random_unit_at(random_pos, CHESS_ENEMIES)
	
	# STAIRS
	random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, 0))
	while not world.is_empty(random_pos) or Vector2(random_pos - world.player.location).length()<MAPSIZE_Y*0.7:
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, 0))
	ground_tilemap.set_cell(random_pos, tile_ids["STAIRS"] , Vector2i(0, 0))
	
	# CHEST
	random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, 0))
	while not world.is_empty(random_pos) or Vector2(random_pos - world.player.location).length()<MAPSIZE_Y*0.7:
		random_pos = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X), randi_range(-MAPSIZE_Y, 0))
	_create_unit_at(random_pos, chest_scene)



func _create_borders(start_x, end_x, start_y, end_y):
	_paint_area(wall_tilemap, Vector2i(start_x-2,start_y-2),Vector2i(start_x-1,end_y+2), tile_ids["OBSIDIAN"]) # left wall
	_paint_area(wall_tilemap, Vector2i(start_x-2,start_y-2),Vector2i(end_x+2,start_y-1), tile_ids["OBSIDIAN"]) # up wall
	_paint_area(wall_tilemap, Vector2i(end_x+1,start_y-2),Vector2i(end_x+2,end_y+2), tile_ids["OBSIDIAN"]) # right wall
	_paint_area(wall_tilemap, Vector2i(start_x-2,end_y+1),Vector2i(end_x+2,end_y+2), tile_ids["OBSIDIAN"]) # down wall

func _take_random_walk_step(randomwalk_loc, prev_step, MAPSIZE_X, MAPSIZE_Y):
	var available_directions = [Vector2i.UP, Vector2i.DOWN,Vector2i.LEFT, Vector2i.RIGHT]
	available_directions.erase(-prev_step)
	if randomwalk_loc.x == MAPSIZE_X:
		available_directions.erase(Vector2i.RIGHT)
	if randomwalk_loc.x == -MAPSIZE_X:
		available_directions.erase(Vector2i.LEFT)
	if randomwalk_loc.y == MAPSIZE_Y:
		available_directions.erase(Vector2i.DOWN)
	if randomwalk_loc.y == -MAPSIZE_Y:
		available_directions.erase(Vector2i.UP)
	#if prev_step in available_directions:
	#	return prev_step
	return available_directions.pick_random()

func _find_wall(MAPSIZE_X, MAPSIZE_Y):
	# used for generating treasures deep inside walls
	var random_loc = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X),randi_range(-MAPSIZE_Y, MAPSIZE_Y))
	var _max_tries = 100
	while _max_tries>0:
		_max_tries -= 1
		if _max_tries < 10 and wall_tilemap.get_cell_source_id(random_loc) != tile_ids["STONE"]:
			return random_loc
		var all_stone = true
		for x in [-1,0,1]:
			for y in [-1,0,1]:
				if wall_tilemap.get_cell_source_id(random_loc+Vector2i(x,y)) != tile_ids["STONE"]:
					all_stone = false
		if all_stone:
			break
		random_loc = Vector2i(randi_range(-MAPSIZE_X, MAPSIZE_X),randi_range(-MAPSIZE_Y, MAPSIZE_Y))
	return random_loc

func randomwalk_to_air(start_loc : Vector2i, MAPSIZE_X: int, MAPSIZE_Y: int):
	var randomwalk_loc: Vector2i = start_loc
	var visited = []
	var prev_step := Vector2i.ZERO
	while true:
		if world.is_empty(randomwalk_loc):
			break
		visited.append(randomwalk_loc)
		prev_step = _take_random_walk_step(randomwalk_loc, prev_step, MAPSIZE_X, MAPSIZE_Y)
		randomwalk_loc += prev_step
	for loc in visited:
		if randf()<0.05: # spike ground
			ground_tilemap.set_cell(loc, [tile_ids["SPIKES"], tile_ids["NOSPIKES"]].pick_random(), Vector2i(0, 0))
		wall_tilemap.set_cell(loc, -1, Vector2i(0, 0))

func _paint_area(tilemap_layer: TileMapLayer, from_location: Vector2i, to_location: Vector2i, tile_id: int) -> void:
	var min_vec = Vector2(min(from_location.x, to_location.x), min(from_location.y, to_location.y))
	var max_vec = Vector2(max(from_location.x, to_location.x), max(from_location.y, to_location.y))
	for x in range(min_vec.x, max_vec.x + 1):
		for y in range(min_vec.y, max_vec.y + 1):
			tilemap_layer.set_cell(Vector2i(x, y), tile_id , Vector2i(0, 0))

func _create_random_unit_at(location: Vector2i, dicts : Array):
	var _enemy = dicts.pick_random()
	while _enemy["level"]>world.current_floor:
		_enemy = dicts.pick_random()
		print(_enemy["level"], " ? " ,world.current_floor)
	if world.is_empty(location, _enemy.get("fatness",Vector2i(1,1))):
		_create_unit_at(location, _enemy["scene"])

func _create_unit_at(location: Vector2i, scene : PackedScene):
	if world.is_empty(location):
		var thing: Unit = scene.instantiate()
		thing.position = World.loc_to_pos(location)
		world.units.add_child(thing)
		if thing is Enemy and randf() < 0.1:
			thing.shield = 1
		return thing
	return false

func _create_spell_room(center_loc: Vector2i) -> void:
	_paint_area(ground_tilemap, center_loc-Vector2i(2,2), center_loc+Vector2i(2,2), tile_ids["WOOD"])
	_paint_area(wall_tilemap, center_loc-Vector2i(2,2), center_loc+Vector2i(2,2), tile_ids["OBSIDIAN"])
	_paint_area(wall_tilemap, center_loc-Vector2i(1,1), center_loc+Vector2i(1,1), -1)
	
	#doorway
	var door_offset = (Vector2i.RIGHT if center_loc.x < 0 else Vector2i.LEFT)*2
	wall_tilemap.set_cell(center_loc+door_offset, -1 , Vector2i(0, 0))
	_paint_area(wall_tilemap, center_loc, center_loc+door_offset*2, -1)
	_create_unit_at(center_loc+door_offset, rock_scene)
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
