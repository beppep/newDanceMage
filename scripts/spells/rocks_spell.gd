extends Spell

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")
@onready var wall_tileset := $"/root/World/TileMapLayerWalls"
@onready var world := $"/root/World"


func cast():
	for direction in [Vector2(1,1), Vector2(1,-1), Vector2(-1,1), Vector2(-1,-1)]:
		for i in range(RANGE):
			var target_cell = Vector2i(direction * (1+i))
			for unit in caster.get_node("/root/World/Units").get_children():
				var enemy_cell = wall_tileset.local_to_map(unit.global_position)
				if enemy_cell == target_cell and unit != caster:
					unit.forced_move(direction)
					break
	queue_free()
