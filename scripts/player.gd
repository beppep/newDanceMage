extends Unit

var fireball_spell = preload("res://assets/resources/spells/fireball_spell.tres")
var wind_spell = preload("res://assets/resources/spells/wind_spell.tres")


var move = Vector2.ZERO
var move_history: Array = []  # stores Vector2 positions
var recipe_book = [[Vector2i.UP, Vector2i.DOWN], [Vector2i.UP, Vector2i.UP],]
var spell_book = [fireball_spell, wind_spell]

func process_turn(world: World):
	while not check_move_input():
		await get_tree().create_timer(1.0 / 60.0).timeout

	move_history.append(Vector2i(move))
	var move_frames_remaining = 0
	if world.is_empty(move * TILE_SIZE + position):
		move_frames_remaining = MOVE_FRAMES

	while move_frames_remaining > 0:
		position += move * TILE_SIZE / MOVE_FRAMES
		move_frames_remaining -= 1
		await get_tree().create_timer(1.0 / 60.0).timeout

	var current_spell_nr = 0
	while current_spell_nr < spell_book.size():
		if check_recipe(recipe_book[current_spell_nr]):
			cast_spell(spell_book[current_spell_nr])
		current_spell_nr += 1

	turn_done.emit()

func check_move_input():
	var got_input = true
	if Input.is_action_pressed("move_up"):
		move = Vector2.UP
		anim.play("up")
	elif Input.is_action_pressed("move_down"):
		move = Vector2.DOWN
		anim.play("down")
	elif Input.is_action_pressed("move_left"):
		move = Vector2.LEFT
		anim.play("right") # flip when walking left
		anim.flip_h = true
	elif Input.is_action_pressed("move_right"):
		move = Vector2.RIGHT
		anim.play("right")
		anim.flip_h = false
	else:
		got_input = false
	return got_input

func check_recipe(recipe):
	if move_history.slice(-recipe.size(), move_history.size()) == recipe:
		return true
	else:
		return false

func cast_spell(spell_resource: SpellResource):
	if spell_resource.spell_script:
		var spell = spell_resource.spell_script.new(self)  # instantiate makes a node2D
		spell.caster = self
		add_child(spell)
		spell.cast()


func end_turn():
	pass
