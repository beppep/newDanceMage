# FireballEffect.gd
extends Node2D

@export var TILESIZE := 16
@export var move_speed := 4.0  # pixels per frame
@export var LIFETIME = 100

@onready var wall_tileset : TileMapLayer = $"/root/World/Level/TileMapLayerWalls"
@onready var world: World = get_tree().current_scene
@onready var player: Player = world.player
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


var direction := Vector2i.RIGHT
var caster : Unit # player (or enemy!?) casting the spell
var owner_spell : Spell # if you assign this from the spell you must also define a hit() behaviour in the spell
var age := 0
var location: Vector2i = World.pos_to_loc(position)
var hit = false

func _ready():
	location = World.pos_to_loc(position)

func _physics_process(_delta):
	if hit:
		return
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
		hit = true
		if owner_spell:
			owner_spell.hit(self, location)
		else:
			world.deal_damage_at(location)
			queue_free()
			
