extends Unit
class_name Player

var stab_spell = preload("res://assets/resources/spells/stab_spell.tres")

var locked_spells = [
	preload("res://assets/resources/spells/explode_spell.tres"),
	preload("res://assets/resources/spells/fireball_spell.tres"),
	preload("res://assets/resources/spells/wind_spell.tres"),
	preload("res://assets/resources/spells/rock_spell.tres"),
]

var has_input_released = true

var move_history: Array[Vector2i] = []
var recipe_book = [[Vector2i.ZERO]]
var spell_book = [stab_spell]

func _ready() -> void:
	max_health = 3
	health = 3

func process_turn(world: World):
	var move = get_move_input()
	while not has_input_released or move == null:
		await get_tree().create_timer(1.0 / 60.0).timeout
		move = get_move_input()

	has_input_released = false
	move_history.append(move)
	if world.is_empty(location + move):
		location += move

	await get_tree().create_timer(World.TILE_SIZE / speed).timeout
	var current_spell_nr = 0
	while current_spell_nr < spell_book.size():
		var recipe = recipe_book[current_spell_nr]
		world.get_node("MainUI")._on_spells_changed()
		if check_recipe_alignment(recipe) == recipe.size():
			cast_spell(world, spell_book[current_spell_nr])
		current_spell_nr += 1

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
	elif Input.is_action_pressed("move_nowhere"):
		return Vector2i.ZERO
	else:
		has_input_released = true
		return null

func check_recipe_alignment(recipe):
	for i in range(recipe.size()):
		var alignment_size = recipe.size()-i
		if move_history.slice(-alignment_size, move_history.size()) == recipe.slice(0, alignment_size):
			return alignment_size
	return 0

func cast_spell(world: World, spell_resource: SpellResource):
	print("Casting ", spell_resource.name)
	if spell_resource.spell_script:
		var spell = spell_resource.spell_script.new()  # instantiate makes a node2D
		add_child(spell)
		spell.cast(self, world)

func get_facing() -> Vector2i:
	for i in range(move_history.size() - 1, -1, -1):
		var move = move_history[i]
		if move != Vector2i.ZERO:
			return move
	return Vector2i.DOWN


func unlock_random_spell():
	var new_spell = locked_spells.pick_random()
	spell_book.append(new_spell)
	recipe_book.append(create_random_recipe(new_spell.dance_length))

func create_random_recipe(recipe_length :int):
	var all_inputs = [Vector2i.RIGHT, Vector2i.UP, -Vector2i.RIGHT, Vector2i.DOWN, Vector2i.ZERO]
	var recipe = []
	for i in range(recipe_length):
		recipe.append(all_inputs.pick_random())
	return recipe
		
