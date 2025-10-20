extends Node
class_name World

const TILE_SIZE = 16

@onready var units: Units = $Units
@onready var wall_tilemap = $TileMapLayerWalls
@onready var player: Player = units.get_node("Player")

func _ready() -> void:
	units.start()
	$map_generator.generate_map()

func _process(_delta):
	pass

func is_wall_at(location: Vector2i) -> bool:
	var cell = wall_tilemap.local_to_map(loc_to_pos(location))
	var tile_id = wall_tilemap.get_cell_source_id(cell)
	return tile_id != -1

func is_empty(location: Vector2i) -> bool:
	return not is_wall_at(location) and not units.get_unit_at(location)

func deal_damage_to(location: Vector2i, damage: int = 1):
	var unit = units.get_unit_at(location)
	if unit:
		unit.take_damage(damage)

static func pos_to_loc(position: Vector2) -> Vector2i:
	return Vector2i(floori(position.x / TILE_SIZE), floori(position.y / TILE_SIZE))

static func loc_to_pos(location: Vector2i) -> Vector2:
	return Vector2(location * TILE_SIZE) + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
