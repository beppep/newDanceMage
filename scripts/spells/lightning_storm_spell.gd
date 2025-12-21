extends Spell

@export var lightning_scene: PackedScene = preload("res://scenes/particles/Lightning.tscn")

var remaining_lightnings = 3
const RADIUS = 4
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
		var best_target = null
		var closest_distance = INF

		# CODE FOR FINDING CLOSEST ENEMY AND SNIPE IT
		for unit in targets:
			var distance = Vector2(unit.location - caster.location).length()
			if distance < closest_distance and distance < RADIUS:
				closest_distance = distance
				best_target = unit
		
		var strike_pos
		if best_target:
			world.deal_damage_at(best_target.location)
			strike_pos = best_target.global_position
		else:
			strike_pos = World.loc_to_pos(Vector2i(randi_range(-2,2),randi_range(-2,2)) + caster.location)
			
				
		var lightning = lightning_scene.instantiate()
		add_child(lightning)
		lightning.global_position = strike_pos
		
		time_until_next_strike = TIME_BETWEEN_STRIKES
	else:
		queue_free()
