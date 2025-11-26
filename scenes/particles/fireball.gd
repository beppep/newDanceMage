# FireballEffect.gd
extends Node2D

@export var TILESIZE := 16
@export var move_speed := 4.0  # pixels per frame
@export var LIFETIME = 100

@onready var wall_tileset : TileMapLayer = $"/root/World/TileMapLayerWalls"
@onready var world = get_tree().current_scene
@onready var player = world.player


var direction := Vector2.RIGHT
var caster # player (or enemy!?) casting the spell
var age = 0
var location = World.pos_to_loc(position)


func _ready():
	location = World.pos_to_loc(position)

func _physics_process(_delta):
	# Move continuously (async?!)
	global_position += direction * move_speed
	age += 1
	if age > LIFETIME:
		queue_free()
		return

	location = World.pos_to_loc(global_position)
	_check_collision()

func _check_collision():
	var cell = wall_tileset.get_cell_source_id(location)
	if cell != -1:
		queue_free()
		return

	for unit in $"/root/World/Units".get_children():
		if not is_instance_valid(unit) or unit.is_queued_for_deletion():
			continue
		if unit.location == location and unit != player:
			await unit.take_damage()
			queue_free()
			
