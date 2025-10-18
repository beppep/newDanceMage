extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var wall_tilemap = $"../../TileMapLayerWalls"
@onready var units = get_parent()

const TILE_SIZE = 16
const MOVE_FRAMES = 8  # time it takes to move one step

var is_turn_active := false
var move: Vector2 = Vector2.ZERO
var move_frames_remaining: = 0
var move_history: Array = []  # stores Vector2 positions

func start_turn():
	is_turn_active = true

func _physics_process(_delta): # called at 60 fps
	if not is_turn_active:
		return
	
	if move_frames_remaining>0:
		position += move * TILE_SIZE / MOVE_FRAMES
		move_frames_remaining -= 1
	else:
		_await_move_input()

func _await_move_input():
	var got_input = true
	if Input.is_action_just_pressed("move_up"):
		move = Vector2.UP
		anim.play("up")
	elif Input.is_action_just_pressed("move_down"):
		move = Vector2.DOWN
		anim.play("down")
	elif Input.is_action_just_pressed("move_left"):
		move = Vector2.LEFT
		anim.play("right") # flip when walking left
		anim.flip_h = true
	elif Input.is_action_just_pressed("move_right"):
		move = Vector2.RIGHT
		anim.play("right")
		anim.flip_h = false
	else:
		got_input = false
	
	if got_input:
		move_history.append(move)
		if can_move_to(move * TILE_SIZE + position):
			move_frames_remaining = MOVE_FRAMES


func can_move_to(pos: Vector2) -> bool:
	return not _is_wall_at(pos) and not _is_occupied(pos)

func _is_occupied(pos: Vector2) -> bool:
	for unit in units.get_children():
		if unit.position == pos:
			return true
	return false
	
func _is_wall_at(pos: Vector2) -> bool:
	var cell = wall_tilemap.local_to_map(pos)
	var tile_id = wall_tilemap.get_cell_source_id(cell)
	return tile_id != -1

func end_turn():
	is_turn_active = false
