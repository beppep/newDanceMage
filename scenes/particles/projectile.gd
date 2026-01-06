# FireballEffect.gd
extends Node2D

@export var TILESIZE := 16
@export var move_speed := 4.0  # pixels per frame
@export var LIFETIME = 100

@onready var wall_tileset : TileMapLayer = $"/root/World/Level/TileMapLayerWalls"
@onready var world: World = get_tree().current_scene
@onready var player: Player = world.player


var direction := Vector2i.RIGHT
var caster # player (or enemy!?) casting the spell
var age = 0
var location = World.pos_to_loc(position)


func _ready():
	location = World.pos_to_loc(position)

func _physics_process(_delta):
	# Move continuously (async?!)
	global_position += Vector2(direction) * move_speed
	age += 1
	if age > LIFETIME:
		queue_free()
		return

	location = World.pos_to_loc(global_position)
	_check_collision()

func _check_collision():
	if not world.is_empty(location) and not location == caster.location:
		world.deal_damage_at(location)
		queue_free()
			
