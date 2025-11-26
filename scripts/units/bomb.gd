extends Unit
class_name Bomb


var age := 0
var is_dying := false

func _ready() -> void:
	super()
	anim.play("age0")
	
func process_turn():
	age += 1
	anim.play("age"+str(age))
	if age >= 3:
		await die()

func die():
	if is_dying or is_queued_for_deletion(): # prevent infinite loops
		return
	is_dying = true
	
	await get_tree().create_timer(0.1).timeout
	
	world.particles.make_cloud(location, "fire")
	
	
	for offset in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i(1,1), Vector2i(1,-1), Vector2i(-1,1), Vector2i(-1,-1)]:
		await world.deal_damage_at(location + offset)
	
	super() # free before chain reaction
