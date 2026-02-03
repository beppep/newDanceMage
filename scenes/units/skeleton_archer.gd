extends Enemy


var projectile_scene = load("res://scenes/particles/Projectile.tscn")

var TARGET_OFFSETS: Array[Vector2i] = [
		Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(-1,2),
		Vector2i(0,-1),Vector2i(0,2),
		Vector2i(1,-1),Vector2i(1,2),
		Vector2i(2,-1),Vector2i(2,0),Vector2i(2,1),Vector2i(2,2)
	] #lol

var regrowth_progress = 0

func _ready():
	super()
	attack_range = 3
	max_health = 2
	health = 2

func do_move():
	var loc = world.player.location
	while not world.is_empty(loc):
		loc = world.player.location + Vector2i(randi_range(-4,4), randi_range(-4,4))
	world.particles.make_cloud(location, "ectoplasm")
	teleport_to(loc)
	world.particles.make_cloud(location, "ectoplasm")


func get_possible_targets() -> Array[Vector2i]:
	return target_with_directions(CARDINAL_DIRECTIONS)

func get_attack_offsets(offset: Vector2i) -> Array[Vector2i]:
	var direction: Vector2i = offset / abs(offset.x+offset.y)
	return target_with_directions([direction])


func perform_attack():
	var offset = attack_offsets.back()
	var direction: Vector2i = offset / abs(offset.x+offset.y)
	var arrow = projectile_scene.instantiate()
	#fireball.global_position = caster.global_position
	arrow.rotation = Vector2(direction).angle()  # rotate to match direction
	arrow.direction = direction
	arrow.attack_range = attack_range
	arrow.caster = self
	arrow.move_speed = 0.2
	add_child(arrow)
	arrow.anim.play("arrow")
	
	attack_offsets = []
	
	while arrow in get_children():
		await get_tree().process_frame


func process_turn():
	if health <= 1:
		anim.play("dead")
		if randf() < 0.8:
			regrowth_progress += 1
			if regrowth_progress>2:
				regrow()
	else:
		super()

func regrow():
	health = 2
	anim.play("idle")

func take_damage(amount=1):
	await super(amount)
	if health <= 1:
		anim.play("dead")
		attack_offsets = []
		regrowth_progress = 0
