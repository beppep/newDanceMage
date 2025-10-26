extends Node
class_name World

const TILE_SIZE = 16

@onready var units: Units = $Units
@onready var wall_tilemap = $TileMapLayerWalls
@onready var player: Player = units.get_node("Player")
@onready var particles: = $Particles

func _ready() -> void:
	units.start()
	$map_generator.generate_map()

func _process(_delta):
	pass

func is_wall_at(location: Vector2i) -> bool:
	var cell = wall_tilemap.local_to_map(loc_to_pos(location))
	var tile_id = wall_tilemap.get_cell_source_id(cell)
	return tile_id != -1

func debug():
	for i in units.get_children(): # Calling this does crazy shit. :/
		i.location = i.location

func is_empty(location: Vector2i, fatness = Vector2i(1,1), except=null, log=false) -> bool:
	for x in range(fatness.x):
		for y in range(fatness.y):
			var loc = location + Vector2i(x,y)
			if log:
				print(x,y, " : ", loc, is_wall_at(loc),units.get_unit_at(loc))
			if is_wall_at(loc) or (units.get_unit_at(loc, log) and units.get_unit_at(loc)!=except):
				return false
	return true

func deal_damage_to(location: Vector2i, damage: int = 1):
	var unit = units.get_unit_at(location)
	if unit:
		unit.take_damage(damage)

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
