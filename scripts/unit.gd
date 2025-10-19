extends Node2D
class_name Unit


const TILE_SIZE = 16
const MOVE_FRAMES = 8


@onready var wall_tilemap = $"../../TileMapLayerWalls"
@onready var units = $"/root/World/Units"
@onready var anim = $AnimatedSprite2D


enum Phase { AWAIT_INPUT, MOVING, CAST_NEXT_SPELL, AWAIT_SPELL_END, NOT_MY_TURN }
var phase := Phase.NOT_MY_TURN

var move_dir: Vector2 = Vector2.ZERO
var move_frames_remaining: = 0

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


func _physics_process(_delta): # called at 60 fps
	match phase:
		Phase.NOT_MY_TURN:
			return
		
		Phase.MOVING:
			position += move_dir * TILE_SIZE / MOVE_FRAMES
			move_frames_remaining -= 1
			if move_frames_remaining == 0:
				phase = Phase.NOT_MY_TURN

func forced_move(direction):
	if is_empty(move_dir * TILE_SIZE + position):
		move_frames_remaining = MOVE_FRAMES
		phase = Phase.MOVING
