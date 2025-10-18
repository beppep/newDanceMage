extends Node

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")
@onready var wall_tileset := $"/root/World/TileMapLayerWalls"


var caster  # player or unit casting the spell

var RANGE = 10

func _init(_caster):
	caster = _caster
	#direction = caster.direction  # assumes your player has this (Vector2.UP, etc.)

func cast():
	for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		# push in reverse order
		for i in range(RANGE):
			var target_cell = Vector2i(direction * RANGE-i)
			for unit in $"/root/World/Units".get_children():
				var enemy_cell = wall_tileset.local_to_map(unit.global_position)
				if enemy_cell == target_cell and unit != caster:
					unit.forced_move(direction)
					break
