extends Spell

@export var rock_scene: PackedScene = preload("res://scenes/units/Rock.tscn")
@onready var wall_tileset := $"/root/World/TileMapLayerWalls"


func cast():
	for direction in [Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
		var target_cell = get_parent().location + direction
		if world.is_empty(target_cell):
			var rock = rock_scene.instantiate()
			rock.location = target_cell
			rock.position = get_parent().position
			#rock.position = target_cell*world.TILE_SIZE + Vector2i(0,-100)
			world.get_node("Units").add_child(rock)
	queue_free()
