extends Node2D

@export var LIFETIME = 12

#@onready var wall_tileset := $"/root/World/TileMapLayerWalls"
#@onready var world = get_tree().current_scene
#@onready var player = world.player
@onready var anim = $AnimatedSprite2D


var direction := Vector2.RIGHT
var caster # player or enemy casting the spell
var age = 0

func _ready():
	anim.play("default")
	#print("born")

func _physics_process(_delta):
	age += 1
	if age > LIFETIME:
		#print("rip")
		queue_free()
