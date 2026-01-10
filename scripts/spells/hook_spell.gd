extends Spell




@export var projectile_scene: PackedScene = preload("res://scenes/particles/Projectile.tscn")

var caster

func cast(_caster: Unit):
	caster = _caster
	var directions = [caster.get_facing()]
	if caster.items.get("four_way_shot", 0):
		directions = [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]
	for direction in directions:
		var hook = projectile_scene.instantiate()
		#hook.global_position = caster.global_position
		hook.rotation = Vector2(direction).angle()  # rotate to match direction
		hook.direction = direction
		hook.caster = caster
		add_child(hook)
		hook.anim.play("hook")
		hook.owner_spell = self

func hit(proj, loc):
	var target = world.units.get_unit_at(loc)
	if target:
		if target.fatness != Vector2i(1,1): # TODO: make logic for fat enemies
			target.take_damage()
		else:
			target.location = caster.location + proj.direction 
			for i in range(1, 8+1):
				proj.global_position = World.loc_to_pos(loc*(8-i) + (caster.location + proj.direction)*i)/8 + Vector2(World.TILE_SIZE, World.TILE_SIZE)/2
				await get_tree().process_frame
			#await GlobalTimers.delay_frames(8)
			await world.deal_damage_at(caster.location + proj.direction)
	proj.queue_free()
	

func _physics_process(_delta): # dies when children die
	if get_child_count() == 0:
		queue_free()







# old hook spell. no projectile => no animation
			
#func cast(caster: Unit):
#	var target = world.get_closest_unit(caster.location, caster.get_facing())
#	if target:
#		target.location = caster.location + caster.get_facing()
#		await GlobalTimers.delay_frames(8)
#		await world.deal_damage_at(caster.location + caster.get_facing())
#	
#	life_time = 8
#	#queue_free()
