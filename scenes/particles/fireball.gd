# FireballEffect.gd
extends Node2D

@export var direction := Vector2.RIGHT
@export var move_speed := 4.0  # pixels per frame
@export var TILESIZE := 16
@export var units: Node  # a reference to your grid system (set on spawn)
@export var on_done_target: Node  # who to notify when finished
@export var on_done_method: String = "on_spell_done"

@onready var wall_tileset := $"/root/World/WallTileMapLayer"

var _tile_pos: Vector2i

func _ready():
	_tile_pos = wall_tileset.world_to_tile(global_position)

func _physics_process(_delta):
	# Move continuously until you reach the next tile center
	global_position += direction * move_speed

	var target_tile = wall_tileset.world_to_tile(global_position)
	if target_tile != _tile_pos:
		_tile_pos = target_tile
		if _check_collision():
			_end_spell()

func _check_collision() -> bool:
	var cell = wall_tileset.get_cell_source_id(_tile_pos)
	if cell != -1:
		return true

	for enemy in $"/root/World/Units".get_children():
		var enemy_cell = (enemy.global_position / TILESIZE).floor()
		if enemy_cell == cell:
			enemy.take_damage(10)
			queue_free()
			return true
	
	return false

func _end_spell():
	if on_done_target and on_done_method != "":
		on_done_target.call(on_done_method, self)
	queue_free()
