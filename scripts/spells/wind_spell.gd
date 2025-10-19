extends Spell

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")
@onready var wall_tileset := $"/root/World/TileMapLayerWalls"


var anim_timer = 8
var RANGE = 10

func cast():
	for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		# push in reverse order # nvm fuck that too annoying
		for i in range(RANGE):
			var target_cell = Vector2i(direction * (1+i))
			for unit in caster.get_node("/root/World/Units").get_children():
				var enemy_cell = wall_tileset.local_to_map(unit.global_position)
				if enemy_cell == target_cell and unit != caster:
					#unit.forced_move(direction)
					break

func _physics_process(_delta): # called at 60 fps
	anim_timer -= 1
	if anim_timer <=0:
		queue_free()
