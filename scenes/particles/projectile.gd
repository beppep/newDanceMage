# FireballEffect.gd
extends Node2D

@export var TILESIZE := 16
@export var move_speed := 0.5  # tiles per frame

@onready var wall_tileset : TileMapLayer = $"/root/World/Level/TileMapLayerWalls"
@onready var world: World = get_tree().current_scene
@onready var player: Player = world.player
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


var direction := Vector2i.RIGHT
var caster : Unit # player (or enemy!?) casting the spell
var owner_spell : Spell # if you assign this from the spell you must also define a hit() behaviour in the spell
var age := 0
var location: Vector2i # read only
var start_location : Vector2i
var hit = false
var attack_range := 10

func _ready():
	start_location = World.pos_to_loc(global_position)
	location = start_location

func _physics_process(_delta):
	if hit:
		return
	# Move continuously (async?!)
	age += 1
	location = start_location + int(move_speed * age) * direction
	global_position = World.loc_to_pos(start_location) + Vector2(direction) * move_speed * world.TILE_SIZE * age
	if int(move_speed * age) > attack_range:
		queue_free()
		return

	_check_collision()

func _check_collision():
	if not world.is_empty(location):
		var target = world.units.get_unit_at(location)
		if target:
			if target == caster:
				return # ally
			else:
				hit = true
				if owner_spell:
					owner_spell.hit(self, location)
				else:
					await world.deal_damage_at(location)
					queue_free()
		else:
			# no unit means wall
			queue_free()
