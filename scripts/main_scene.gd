extends Node
class_name World

const TILE_SIZE = 16

@onready var units = $Units
@onready var wall_tilemap = $TileMapLayerWalls
@onready var player = units.get_node("Player")
var unit_thread: Thread

enum Phase { PLAYER_MOVEMENT, SPELLCASTING, ENEMY }

var state := Phase.PLAYER_MOVEMENT

func _ready() -> void:
	units.start()

func _process(_delta):
	pass

func is_wall_at(location: Vector2i) -> bool:
	var cell = wall_tilemap.local_to_map(location * TILE_SIZE)
	var tile_id = wall_tilemap.get_cell_source_id(cell)
	return tile_id != -1

func is_empty(location: Vector2i) -> bool:
	return not is_wall_at(location) and not units.get_unit_at(location)
