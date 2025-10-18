extends Node2D
class_name Unit


@onready var wall_tilemap = $"../../TileMapLayerWalls"
@onready var units = $"/root/World/Units"


func is_empty(pos: Vector2) -> bool:
	return not _is_wall_at(pos) and not _is_occupied(pos)

func _is_wall_at(pos: Vector2) -> bool:
	var cell = wall_tilemap.local_to_map(pos)
	var tile_id = wall_tilemap.get_cell_source_id(cell)
	return tile_id != -1

func _is_occupied(pos: Vector2) -> bool:
	for unit in units.get_children():
		if unit.position == pos:
			return true
	return false


func forced_move(direction):
	if can_move_to(move * TILE_SIZE + position):
		move_frames_remaining = MOVE_FRAMES
		phase = Phase.MOVING
