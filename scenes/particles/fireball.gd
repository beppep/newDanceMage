# FireballEffect.gd
extends Node2D

@export var TILESIZE := 16
@export var move_speed := 4.0  # pixels per frame
@export var LIFETIME = 100

@onready var wall_tileset := $"/root/World/TileMapLayerWalls"
@onready var world = get_tree().current_scene
@onready var player = world.player


var direction := Vector2.RIGHT
var caster # player or enemy casting the spell
var age = 0

var _tile_pos: Vector2i

func _ready():
	_tile_pos = wall_tileset.local_to_map(global_position)

func _physics_process(_delta):
	# Move continuously until you reach the next tile center
	global_position += direction * move_speed
	age += 1
	if age > LIFETIME:
		queue_free()

	var target_tile = wall_tileset.local_to_map(global_position)
	if target_tile != _tile_pos:
		_tile_pos = target_tile
		_check_collision()

func _check_collision():
	var cell = wall_tileset.get_cell_source_id(_tile_pos)
	if cell != -1:
		queue_free()

	for enemy in $"/root/World/Units".get_children():
		var enemy_cell = Vector2i((enemy.global_position / TILESIZE).floor())
		if enemy_cell == _tile_pos and enemy != player:
			#enemy.take_damage(1)
			queue_free()
			
