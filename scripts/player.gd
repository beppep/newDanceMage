extends Unit

var fireball_spell = preload("res://assets/resources/spells/fireball_spell.tres")
var wind_spell = preload("res://assets/resources/spells/wind_spell.tres")

var has_input_released = true

var move_history: Array = []  # stores Vector2 positions
var recipe_book = [[Vector2i.UP, Vector2i.DOWN], [Vector2i.UP, Vector2i.UP],]
var spell_book = [fireball_spell, wind_spell]

func process_turn(world: World):
	var move = get_move_input()
	while not has_input_released or move == null:
		await get_tree().create_timer(1.0 / 60.0).timeout
		move = get_move_input()

	has_input_released = false
	move_history.append(move)
	if world.is_empty(location + move):
		location += move

	var current_spell_nr = 0
	while current_spell_nr < spell_book.size():
		if check_recipe(recipe_book[current_spell_nr]):
			cast_spell(spell_book[current_spell_nr])
		current_spell_nr += 1

	turn_done.emit()

func get_move_input():
	if Input.is_action_pressed("move_up"):
		anim.play("up")
		return Vector2i.UP
	elif Input.is_action_pressed("move_down"):
		anim.play("down")
		return Vector2i.DOWN
	elif Input.is_action_pressed("move_left"):
		anim.play("right") # flip when walking left
		anim.flip_h = true
		return Vector2i.LEFT
	elif Input.is_action_pressed("move_right"):
		anim.play("right")
		anim.flip_h = false
		return Vector2i.RIGHT
	else:
		has_input_released = true
		return null

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
