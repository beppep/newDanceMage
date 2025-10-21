extends Unit
class_name Player

var stab_spell = preload("res://assets/resources/spells/stab_spell.tres")

var locked_spells = [
	preload("res://assets/resources/spells/explode_spell.tres"),
	preload("res://assets/resources/spells/fireball_spell.tres"),
	preload("res://assets/resources/spells/wind_spell.tres"),
	preload("res://assets/resources/spells/rock_spell.tres"),
	preload("res://assets/resources/spells/bomb_spell.tres"),
]

var buffered_input = null
var move_history: Array[Vector2i] = []
var recipe_book = [[Vector2i.ZERO]]
var spell_book = [stab_spell]

func _ready() -> void:
	max_health = 3
	health = 3

func _process(_delta: float) -> void:
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

func process_turn(world: World):
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
			cast_spell(world, spell_book[current_spell_nr])
		current_spell_nr += 1

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
		
