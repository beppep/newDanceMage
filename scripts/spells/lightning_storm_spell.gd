extends Spell

@export var lightning_scene: PackedScene = preload("res://scenes/particles/Lightning.tscn")

var remaining_lightnings
var RADIUS = 3
var time_until_next_strike = 0

func cast(caster: Unit): # equivalent to ready?
	remaining_lightnings = 10
	_random_lightning_strike(caster)
		
func _physics_process(delta: float) -> void:
	if time_until_next_strike<=0:
		if remaining_lightnings:
			remaining_lightnings -= 1
			_random_lightning_strike(world.player) # caster should be remembrered?
	else:
		time_until_next_strike -= 1

		
func _random_lightning_strike(caster):
	var offset := Vector2i.ZERO
	while offset == Vector2i.ZERO:
		offset = Vector2i(randi_range(-RADIUS,RADIUS),randi_range(-RADIUS,RADIUS))
		
	var target = world.units.get_unit_at(caster.location + offset)
	if target:
		target.take_damage(1)
			
	var lightning = lightning_scene.instantiate()
	lightning.global_position = world.TILE_SIZE * Vector2(offset)
	add_child(lightning)
	
	time_until_next_strike = 1
