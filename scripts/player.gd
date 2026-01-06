extends Unit
class_name Player

var stab_spell = preload("res://assets/resources/spells/stab_spell.tres")

var locked_spell_paths : Array[String] = [ # i had issues trying to keep the spellresources in a list. for some reason preload returns like a weird reference
	"res://assets/resources/spells/beamstar_spell.tres",
	"res://assets/resources/spells/bomb_spell.tres",
	"res://assets/resources/spells/crystal_spell.tres",
	"res://assets/resources/spells/dash_spell.tres",
	"res://assets/resources/spells/everything_spell.tres",
	"res://assets/resources/spells/explode_spell.tres",
	"res://assets/resources/spells/extra_turn_spell.tres",
	"res://assets/resources/spells/fireball_spell.tres",
	"res://assets/resources/spells/freeze_spell.tres",
	"res://assets/resources/spells/heal_spell.tres",
	"res://assets/resources/spells/hook_spell.tres",
	"res://assets/resources/spells/lightning_storm_spell.tres",
	"res://assets/resources/spells/magnet_spell.tres",
	"res://assets/resources/spells/random_spell.tres",
	"res://assets/resources/spells/rock_spell.tres",
	"res://assets/resources/spells/shield_spell.tres",
	"res://assets/resources/spells/teleport_spell.tres",
	"res://assets/resources/spells/wind_spell.tres",
]

@onready var ui_node : MainUI = world.get_node("MainUI")


var buffered_input = null
var move_history: Array[Vector2i] = []
#var recipe_book: Array = [Globals.selected_character.starting_dance]
var spell_book: Array[SpellResource] = [Globals.selected_character.starting_spell.duplicate()]
#var upgrade_count_book = [0]
var coins = 0
var items = {"exploding_rocks":0, "four_way_shot":0}

var extra_turn = 0

func _ready() -> void:
	super()
	max_health = Globals.selected_character.health
	health = Globals.selected_character.health
	
	# debugging locked_spell_resources having weird references instead of SpellResources
	#var fireball_spell = load(locked_spell_resources[1]
	#print(fireball_spell, fireball_spell is SpellResource) # no
	#fireball_spell = load("res://assets/resources/spells/fireball_spell.tres")
	#print(fireball_spell, fireball_spell is SpellResource) #yes



func _process(_delta: float) -> void:
	if world.floor_tilemap.get_cell_source_id(location)==2:
		world.floor_tilemap.set_cell(location, -1, Vector2i(0, 0))
		coins += 1
	if world.floor_tilemap.get_cell_source_id(location)==1:
		world.floor_tilemap.set_cell(location, -1, Vector2i(0, 0))
		health += 1
	
	var input = get_input()
	if input != null:
		buffered_input = input

func get_input():
	if ui_node.get_card_reward_is_shown():
		return null
	if Input.is_action_just_pressed("move_up"):
		return Vector2i.UP
	elif Input.is_action_just_pressed("move_down"):
		return Vector2i.DOWN
	elif Input.is_action_just_pressed("move_left"):
		return Vector2i.LEFT
	elif Input.is_action_just_pressed("move_right"):
		return Vector2i.RIGHT
	elif Input.is_action_just_pressed("move_nowhere") and not ui_node.get_shop_is_shown():
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
		await get_tree().create_timer(1.0 / 100.0).timeout # let other stuff run while waiting

	update_animation(buffered_input)
	move_history.append(buffered_input)
	if world.is_empty(location + buffered_input):
		location += buffered_input
	elif items.get("push", 0):
		push_units(location, buffered_input)
		if world.is_empty(location + buffered_input):
			location += buffered_input
	buffered_input = null

	await get_tree().create_timer(World.TILE_SIZE / speed).timeout # why
	ui_node._on_spells_changed()
	var current_spell_nr = 0
	var _to_be_cast = spell_book.duplicate()
	while current_spell_nr < _to_be_cast.size():
		var spell = _to_be_cast[current_spell_nr]
		if check_recipe_alignment(spell) == spell.recipe.size():
			await get_tree().process_frame # we need to have this line for the tween to work i have no clue
			# like if you edit a tween on an object thats not ready yet nothing happens
			ui_node.flash_icon(ui_node.spell_container.get_children()[current_spell_nr].get_children()[0])
			
			await cast_spell(_to_be_cast[current_spell_nr]) # cast copy
		current_spell_nr += 1
	

func check_recipe_alignment(spell : SpellResource):
	for i in range(spell.recipe.size()):
		var alignment_size = spell.recipe.size()-i
		if move_history.size() < alignment_size: # no hhistory
			continue
		var move_history_tail = move_history.slice(-alignment_size, move_history.size())
		var recipe_tail = spell.recipe.slice(0, alignment_size)
		var alignment = true
		for j in range(alignment_size):
			if not recipe_tail[j].matches(move_history_tail[j]): # wildcard
				alignment = false
				break
		if alignment:
			return alignment_size
	return 0

func cast_spell(spell_resource: SpellResource):
	print("Casting ", spell_resource.name)
	var spell
	var _did_resolve # for temp spells
	if spell_resource.spell_script: #why would this not happen?
		spell = spell_resource.spell_script.new()  # instantiate makes a node2D?
		add_child(spell)
		_did_resolve = await spell.cast(self)
	else:
		print("NO SPELL SCRIPT for ", spell_resource)
		print("with name ",spell_resource.name)
	while is_instance_valid(spell) and spell in get_children():
		await get_tree().process_frame
	print("Done casting",spell_resource.name)
	if spell_resource.temporary and _did_resolve:
		spell_book.erase(spell_resource)

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
		
		var new_spell : SpellResource = load(locked_spell_paths.pick_random()).duplicate()
		spell_options.append(new_spell)
		recipe_options.append(create_random_recipe(new_spell.dance_length))
	
	var main_ui := $"/root/World/MainUI"
	main_ui.show_card_reward(spell_options, recipe_options)

func unlock(spell: SpellResource, recipe: Array):
	print("Unlocked: ", spell, recipe)
	spell_book.append(spell)
	assert(recipe is Array[Step])
	spell.recipe = recipe
	#recipe_book.append(recipe)
	#upgrade_count_book.append(0)

#func unlock_random_spell():
#	var new_spell = locked_spell_resources.pick_random()
#	spell_book.append(new_spell)
#	recipe_book.append(create_random_recipe(new_spell.dance_length))

func create_random_recipe(recipe_length :int):
	var all_inputs = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.ZERO]
	var recipe: Array[Step] = []
	for i in range(recipe_length):
		recipe.append(Step.make_direction(all_inputs.pick_random()))
	return recipe

func take_damage(amount=1):
	super(amount)
	ui_node.flash_damage()
	await get_tree().create_timer(0.5).timeout

func die():
	print(name, " died a horrible death.")
	#queue_free()
	world.units.is_running = false
	await get_tree().create_timer(5.0).timeout
