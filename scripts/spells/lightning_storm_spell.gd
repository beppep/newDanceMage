extends Spell

@export var lightning_scene: PackedScene = preload("res://scenes/particles/Lightning.tscn")

var remaining_lightnings = 3
const RADIUS = 3
const TIME_BETWEEN_STRIKES = 8

var time_until_next_strike = 0

func cast(caster: Unit): # equivalent to ready?
	remaining_lightnings -= 1
	_random_lightning_strike(caster)
		
func _physics_process(_delta: float) -> void:
	if time_until_next_strike<=0:
		if remaining_lightnings:
			remaining_lightnings -= 1
			_random_lightning_strike(world.player) # caster should be remembrered?
		else:
			queue_free()
	else:
		time_until_next_strike -= 1

		
func _random_lightning_strike(caster):
	var targets = world.units.get_units()
	targets.erase(caster)
	
	if targets:
		var target = targets.pick_random()
		var closest_distance = INF

		# CODE FOR FINDING CLOSEST ENEMY AND SNIPE IT
		for unit in targets:
			var distance = Vector2(unit.location - caster.location).length()
			if distance < closest_distance and distance < RADIUS:
				closest_distance = distance
				target = unit
	
		world.deal_damage_at(target.location)
				
		var lightning = lightning_scene.instantiate()
		add_child(lightning)
		lightning.global_position = target.global_position
		
		time_until_next_strike = TIME_BETWEEN_STRIKES
	else:
		queue_free()
