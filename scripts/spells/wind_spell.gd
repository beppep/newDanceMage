extends Spell
class_name Wind

@export var fireball_scene: PackedScene = preload("res://scenes/particles/Fireball.tscn")
@onready var wall_tileset := $"/root/World/TileMapLayerWalls"


var anim_timer = 8
var RANGE = 10

func cast(caster: Unit, world: World):
	for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		# push in reverse order
		for i in range(RANGE):
			var j = RANGE - i
			var target_cell = caster.location + Vector2i(direction * j)
			var unit = world.units.get_unit_at(target_cell)
			if unit:
				unit.move_in_direction(world, direction)

func _physics_process(_delta): # called at 60 fps
	anim_timer -= 1
	if anim_timer <=0:
		queue_free()
