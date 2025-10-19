extends Node
class_name World

const TILE_SIZE = 16

@onready var units: Units = $Units
@onready var wall_tilemap = $TileMapLayerWalls
@onready var player: Player = units.get_node("Player")

func _ready() -> void:
	units.start()

func _process(_delta):
	pass

func is_wall_at(location: Vector2i) -> bool:
	var cell = wall_tilemap.local_to_map(loc_to_pos(location))
	var tile_id = wall_tilemap.get_cell_source_id(cell)
	return tile_id != -1

func is_empty(location: Vector2i) -> bool:
	return not is_wall_at(location) and not units.get_unit_at(location)

static func pos_to_loc(position: Vector2) -> Vector2i:
	return Vector2i((position + Vector2(TILE_SIZE, TILE_SIZE)) / TILE_SIZE)

static func loc_to_pos(location: Vector2i) -> Vector2:
	return Vector2(location * TILE_SIZE) - Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
