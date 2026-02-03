extends Enemy

var _next_move : String
var _rolling_direction : Vector2i
var jump_center_target_loc : Vector2i

var projectile_scene = load("res://scenes/particles/Projectile.tscn")

func _ready():
	super()
	max_health = 15
	health = 15
	
func choose_intent():
	if randf()<0.5:
		target_roll()
		_next_move = "roll"
	elif randf()<0.5:
		target_shoot()
		_next_move = "shoot"
	else:
		target_jump()
		_next_move = "jump"
	attack_offsets = attack_offsets # trigger setter logic. this is so bad

func process_turn():
	if attack_offsets.is_empty():
		choose_intent()
	else:
		match _next_move:
			"jump":
				await perform_jump()
			"roll":
				await perform_rolling_attack()
			"shoot":
				await perform_shoot()
		if randf()<0.8:
			choose_intent()
	
func get_possible_targets(): # unused
	return []

func target_roll():
	# pick rolling attack direction
	var possible_roll_directions = []
	if world.player.location.x > location.x+1:
		possible_roll_directions.append(Vector2i.RIGHT)
	if world.player.location.x < location.x+1:
		possible_roll_directions.append(Vector2i.LEFT)
	if world.player.location.y > location.y+1:
		possible_roll_directions.append(Vector2i.DOWN)
	if world.player.location.y < location.y+1:
		possible_roll_directions.append(Vector2i.UP)
	_rolling_direction = possible_roll_directions.pick_random()
	
	# target a 3 x 6 area for rolling attack
	attack_offsets = [] # why does this fix anything
	for x in [0,1,2]:
		for y in [0,1,2]:
			attack_offsets.append(3*_rolling_direction + Vector2i(x,y)) 
			if not world.is_wall_at(location + 6*_rolling_direction + Vector2i(x,y)):
				attack_offsets.append(6*_rolling_direction + Vector2i(x,y))

func target_jump():
	attack_offsets = []
	
	var random_center_loc = world.player.location + Vector2i(randi_range(-2, 2), randi_range(-2, 2))
	while world.is_wall_at(random_center_loc - Vector2i(1,1), fatness):
		random_center_loc = world.player.location + Vector2i(randi_range(-2, 2), randi_range(-2, 2))
		print("infy??")
		
	for x in [0,1,2]:
		for y in [0,1,2]:
			attack_offsets.append(Vector2i(x,y) + random_center_loc - Vector2i(1,1) - location)
	jump_center_target_loc = random_center_loc

func target_shoot():
	attack_offsets = []
	for i in range(8):
		for offset in ALL_DIRECTIONS:
			attack_offsets.append(i*offset + Vector2i(1,1))

func perform_rolling_attack():
	attack_offsets = []
	anim.play("round")
	await wait_a_few_frames()
	for j in range(5):
		if world.is_empty(location + _rolling_direction, fatness, self):
			location += _rolling_direction
			await wait_a_few_frames()
		else:
			var _normal = Vector2i(-_rolling_direction.y, _rolling_direction.x)
			for i in [-1, 0, 1]:
				# attack people in the way
				await world.deal_damage_at(location + Vector2i(1,1) + _rolling_direction*2 + _normal*i)
			await wait_a_few_frames()
			if not world.is_empty(location + _rolling_direction, fatness, self):
				location += _rolling_direction
				await wait_a_few_frames()
				location -= _rolling_direction
				await wait_a_few_frames()
				anim.play("default")
				return
	
	
func perform_jump():
	var target_loc = jump_center_target_loc - Vector2i(1,1)
	var _original_loc = location
	var target_units = []
	for offset in attack_offsets:
		var target = world.units.get_unit_at(_original_loc + offset)
		if target and target not in target_units and target != self:
			target_units.append(target)
	attack_offsets = []
	# jump
	world.particles.make_cloud(location, "smoke")
	location = target_loc + Vector2i(0, -8)
	
	await wait_a_few_frames()
		
	for unit in target_units:
		await unit.take_damage()
	world.particles.make_cloud(target_loc, "smoke")
	if world.is_empty(target_loc, fatness, self):
		location = target_loc
	else:
		location = target_loc
		await wait_a_few_frames()
		location = _original_loc + Vector2i(0, -7)
		await wait_a_few_frames()
		location = _original_loc
	await wait_a_few_frames()

func wait_a_few_frames(n = 8):
	for i in range(n):
		await get_tree().process_frame
	
func perform_shoot():
	attack_offsets = []
	for direction in ALL_DIRECTIONS:
		var fireball = projectile_scene.instantiate()
		fireball.rotation = Vector2(direction).angle()  # rotate to match direction
		fireball.direction = direction
		fireball.caster = self
		add_child(fireball)
		fireball.position += World.loc_to_pos(Vector2i(1,1))*0.5
		fireball._ready()
		fireball.anim.play("fireball")
	await wait_a_few_frames()
