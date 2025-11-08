extends Unit
class_name Player

var stab_spell = preload("res://assets/resources/spells/stab_spell.tres")

var locked_spells = [
	preload("res://assets/resources/spells/explode_spell.tres"),
	preload("res://assets/resources/spells/fireball_spell.tres"),
	preload("res://assets/resources/spells/wind_spell.tres"),
	preload("res://assets/resources/spells/rock_spell.tres"),
	preload("res://assets/resources/spells/bomb_spell.tres"),
	preload("res://assets/resources/spells/lightning_storm_spell.tres"),
	preload("res://assets/resources/spells/freeze_spell.tres"),
	preload("res://assets/resources/spells/dash_spell.tres"),
]

var buffered_input = null
var move_history: Array[Vector2i] = []
var recipe_book = [[Vector2i.ZERO]]
var spell_book = [stab_spell]
var coins = 0

func _ready() -> void:
	super()
	max_health = 3
	health = 3

func _process(_delta: float) -> void:
	if world.floor_tilemap.get_cell_source_id(location)==2:
		world.floor_tilemap.set_cell(location, -1, Vector2i(0, 0))
		coins += 1
	if world.ground_tilemap.get_cell_source_id(location)==4:
		#location = Vector2i.ZERO
		world.next_floor()
	
	var input = get_input()
	if input != null:
		buffered_input = input

func get_input():
	if Input.is_action_just_pressed("move_up"):
		return Vector2i.UP
	elif Input.is_action_just_pressed("move_down"):
		return Vector2i.DOWN
	elif Input.is_action_just_pressed("move_left"):
		return Vector2i.LEFT
	elif Input.is_action_just_pressed("move_right"):
		return Vector2i.RIGHT
	elif Input.is_action_just_pressed("move_nowhere"):
		return Vector2i.ZERO
	return null

func update_animation(move: Vector2i):
	match move:
		Vector2i.UP:
			anim.play("up")
		Vector2i.DOWN:
			anim.play("down")
		Vector2i.LEFT:
			anim.play("right") # flip when walking left
			anim.flip_h = true
		Vector2i.RIGHT:
			anim.play("right")
			anim.flip_h = false

func process_turn():
	while buffered_input == null:
		await get_tree().create_timer(1.0 / 100.0).timeout

	update_animation(buffered_input)
	move_history.append(buffered_input)
	if world.is_empty(location + buffered_input):
		location += buffered_input
	buffered_input = null

	await get_tree().create_timer(World.TILE_SIZE / speed).timeout
	var current_spell_nr = 0
	while current_spell_nr < spell_book.size():
		var recipe = recipe_book[current_spell_nr]
		world.get_node("MainUI")._on_spells_changed()
		if check_recipe_alignment(recipe) == recipe.size():
			cast_spell(spell_book[current_spell_nr])
		current_spell_nr += 1

func check_recipe_alignment(recipe):
	for i in range(recipe.size()):
		var alignment_size = recipe.size()-i
		if move_history.slice(-alignment_size, move_history.size()) == recipe.slice(0, alignment_size):
			return alignment_size
	return 0

func cast_spell(spell_resource: SpellResource):
	print("Casting ", spell_resource.name)
	if spell_resource.spell_script:
		var spell = spell_resource.spell_script.new()  # instantiate makes a node2D?
		add_child(spell)
		spell.cast(self)

func get_facing() -> Vector2i:
	for i in range(move_history.size() - 1, -1, -1):
		var move = move_history[i]
		if move != Vector2i.ZERO:
			return move
	return Vector2i.DOWN


func create_card_reward():
	var spell_options = []
	var recipe_options = []
	for i in range(3):
		var new_spell : SpellResource = locked_spells.pick_random()
		spell_options.append(new_spell)
		recipe_options.append(create_random_recipe(new_spell.dance_length))
	
	var main_ui := $"/root/World/MainUI"
	main_ui.show_card_reward(spell_options, recipe_options)

func unlock(spell: SpellResource, recipe: Array):
	print("unlocked ", spell, recipe)
	spell_book.append(spell)
	recipe_book.append(recipe)

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
