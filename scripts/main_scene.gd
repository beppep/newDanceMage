extends Node
class_name World

const TILE_SIZE = 16

@onready var units: Units = $Level/Units
@onready var wall_tilemap : TileMapLayer = $Level/TileMapLayerWalls
@onready var floor_tilemap : TileMapLayer = $Level/TileMapLayerFloor
@onready var ground_tilemap : TileMapLayer = $Level/TileMapLayerGround
@onready var player: Player = units.get_node("Player")
@onready var particles: Particle_spawner = $Particles
var current_floor = 1
var all_spike_locations: Array[Vector2i] = []

func _ready() -> void:
	
	if OS.get_name() == "Android":
		get_tree().root.content_scale_factor = 1.5
		
	print(" GAME START ")
	current_floor = 1
	$map_generator.generate_map_cavestyle()
	units.start()

func next_floor():
	current_floor += 1
	print("current floor: ", current_floor)
	for child in units.get_children():
		if child != player:
			child.queue_free()
	
	if current_floor % 3 == 0:
		$map_generator.generate_boss_room()
	else:
		$map_generator.generate_map_cavestyle()
	#units.start() # DONT!! Then it will run multiple instances of turn order (!!?!)

func _process(_delta):
	pass

func is_wall_at(location: Vector2i) -> bool:
	var cell = wall_tilemap.local_to_map(loc_to_pos(location))
	var tile_id = wall_tilemap.get_cell_source_id(cell)
	return tile_id != -1

func toggle_spikes():
	var _to_go_up = [] # looks cooler if there is time in between imo
	for spike_loc in all_spike_locations:
		var cell = ground_tilemap.get_cell_source_id(spike_loc)
		assert(cell in [Globals.tile_ids["SPIKES"], Globals.tile_ids["NOSPIKES"]]) # this failed!
		var is_up: bool = (cell == Globals.tile_ids["SPIKES"])
		if is_up:
			ground_tilemap.set_cell(spike_loc, Globals.tile_ids["NOSPIKES"], Vector2i(0, 0))
		else:
			_to_go_up.append(spike_loc)
	await get_tree().create_timer(0.1).timeout
	for spike_loc in _to_go_up:
		ground_tilemap.set_cell(spike_loc, Globals.tile_ids["SPIKES"], Vector2i(0, 0))
		if not (units.get_unit_at(spike_loc) and units.get_unit_at(spike_loc) is Crystal):
			deal_damage_at(spike_loc)


func is_empty(location: Vector2i, fatness = Vector2i(1,1), except=null) -> bool:
	for x in range(fatness.x):
		for y in range(fatness.y):
			var loc = location + Vector2i(x,y)
			if is_wall_at(loc) or (units.get_unit_at(loc) and units.get_unit_at(loc)!=except):
				return false
	return true

func deal_damage_at(location: Vector2i, damage: int = 1, except: Unit = null):
	var unit = units.get_unit_at(location)
	if unit and is_instance_valid(unit) and not unit.is_queued_for_deletion() and not unit==except:
		await unit.take_damage(damage)
		
func get_closest_wall(from: Vector2i, direction: Vector2i, max_range: int = 20):
	for i in range(1, max_range + 1):
		var target = from + direction * i
		if is_wall_at(target):
			return i
	return max_range
	
func get_closest_unit(from: Vector2i, direction: Vector2i, max_range: int = 20) -> Unit:
	for i in range(1, max_range + 1):
		var target = from + direction * i
		var unit = units.get_unit_at(target)
		if unit:
			return unit
		elif is_wall_at(target):
			return null
	return null

static func pos_to_loc(position: Vector2) -> Vector2i:
	return Vector2i(floori(position.x / TILE_SIZE), floori(position.y / TILE_SIZE))

static func loc_to_pos(location: Vector2i) -> Vector2:
	return Vector2(location * TILE_SIZE) + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
