extends Node
class_name World

@onready var units = $Units
@onready var wall_tilemap = $TileMapLayerWalls
@onready var player = units.get_node("Player")
var unit_thread: Thread

enum Phase { PLAYER_MOVEMENT, SPELLCASTING, ENEMY }

var state := Phase.PLAYER_MOVEMENT

func _ready() -> void:
	pass

func _process(_delta):
	pass

func is_wall_at(pos: Vector2) -> bool:
	var cell = wall_tilemap.local_to_map(pos)
	var tile_id = wall_tilemap.get_cell_source_id(cell)
	return tile_id != -1

func is_empty(pos: Vector2) -> bool:
	return not is_wall_at(pos) and not units.get_unit_at(pos)
