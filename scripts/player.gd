extends Unit
class_name Player

var test_spell = load("res://assets/resources/spells/self_destruct_spell.tres")


var locked_spell_paths : Array[String] = [ # i had issues trying to keep the spellresources in a typed array. for some reason preload returns like a weird reference instead of a SpellResource
	"res://assets/resources/spells/beamstar_spell.tres",
	"res://assets/resources/spells/bomb_spell.tres",
	"res://assets/resources/spells/crystal_spell.tres",
	"res://assets/resources/spells/dash_spell.tres",
	"res://assets/resources/spells/diamond_spell.tres",
	"res://assets/resources/spells/everything_spell.tres",
	"res://assets/resources/spells/explode_spell.tres",
	"res://assets/resources/spells/extra_turn_spell.tres",
	"res://assets/resources/spells/fireball_spell.tres",
	"res://assets/resources/spells/freeze_spell.tres",
	"res://assets/resources/spells/heal_spell.tres",
	"res://assets/resources/spells/hook_spell.tres",
	"res://assets/resources/spells/lightning_storm_spell.tres",
	"res://assets/resources/spells/random_spell.tres",
	"res://assets/resources/spells/rock_spell.tres",
	"res://assets/resources/spells/self_destruct_spell.tres",
	"res://assets/resources/spells/shield_spell.tres",
	"res://assets/resources/spells/teleport_spell.tres",
	"res://assets/resources/spells/wind_spell.tres",
]

@onready var ui_node : MainUI = world.get_node("MainUI")


var buffered_input = null
var move_history: Array[Vector2i] = []
var spell_book_max = 8 # not implemented
var spell_book: Array[SpellResource] = [Globals.selected_character.starting_spell.duplicate()]
var diamonds = 0
var items = {}
var displayed_items = [] # maybe there should only be one items list, but having the dictionary can be handy for now...

var extra_turn = 0

func _ready() -> void:
	super()
	max_health = Globals.selected_character.health
	health = Globals.selected_character.health
	
	if Globals.selected_character.name == "Armadillo":
		anim.hide()
		anim = $"armadillo"
		anim.show()
	
	# semi jank stuff thats still nice for now:
	spell_book[0].upgrade_count = 9 # upgrading starting spell should not be allowed?
	await get_tree().process_frame
	world.main_ui.pickup_info.get_node("PickupName").text = Globals.selected_character.name # starting character name and descr.
	world.main_ui.pickup_info.get_node("PickupDescription").text = Globals.selected_character.description



func _process(_delta: float) -> void:
	if world.floor_tilemap.get_cell_source_id(location)==Globals.tile_ids["DIAMOND"]:
		world.floor_tilemap.set_cell(location, -1, Vector2i(0, 0))
		diamonds += 1
	if world.floor_tilemap.get_cell_source_id(location)==1:
		world.floor_tilemap.set_cell(location, -1, Vector2i(0, 0))
		health += 1
	world.items.pickup_item_at(location, self)
	
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
		Vector2i.ZERO:
			visual_armadillo_curl()

func process_turn():
	if world.CHEAT:
		health = 5
		max_health = 5
	while buffered_input == null:
		await get_tree().create_timer(1.0 / 100.0).timeout # let other stuff run while waiting
	world.main_ui.pickup_info.hide() # shown if you picked up an item last turn.

	update_animation(buffered_input)
	move_history.append(buffered_input)
	if buffered_input!=Vector2i.ZERO:
		var _did_walk_damage_to_something = false
		if not world.is_empty(location + buffered_input): # someone in the way?
			if items.get("push",0):
				push_units(location, buffered_input)
		if world.is_empty(location + buffered_input):
			location += buffered_input
		else:
			#walking into something
			var new_position = World.loc_to_pos(location) + Vector2(buffered_input)*4
			tween = create_tween().set_trans(Tween.TRANS_LINEAR)
			tween.tween_property(self, "position", new_position, 0.1)
			tween.tween_property(self, "position", World.loc_to_pos(location), 0.1)
			
			if items.get("walk_damage",0)>0:
				world.deal_damage_at(location + buffered_input, items.get("walk_damage",0))
	
	buffered_input = null

	await get_tree().create_timer(World.TILE_SIZE / speed).timeout # why
	ui_node._on_spells_changed()
	var current_spell_nr = 0
	var _to_be_cast = spell_book.duplicate()
	var _emergency_debugging_frame_limit = 0
	while current_spell_nr < _to_be_cast.size():
		var spell_resource = _to_be_cast[current_spell_nr]
		if check_recipe_alignment(spell_resource) == spell_resource.recipe.size():
			await get_tree().process_frame # we need to have this line for the tween to work i have no clue
			# like if you edit a tween on an object thats not ready yet nothing happens
			ui_node.flash_icon(ui_node.spell_container.get_children()[current_spell_nr].get_children()[0])
			#print("await cast")
			await cast_spell(_to_be_cast[current_spell_nr]) # cast copy
			# WARNING: if the spell is freed before cast() returns, the whole game will freeze. the only workaround for this is to not use await but instead make custom signals for everything we want to await
			# might restructure to like an effect queue or some other system instead of cursed awaits...
			#while spell_node in get_children():
			#	await get_tree().process_frame
			#print("dun cast")
		current_spell_nr += 1
		
		_emergency_debugging_frame_limit += 1
		if _emergency_debugging_frame_limit > 500:
			print("ERROR::: CASTING OVER 500 SPELLS!??!?!")
	print("all casts done")
	

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
	var spell : Spell
	
	world.main_ui.flash_spell(spell_resource)
	
	var _did_resolve # for temp spells
	if spell_resource.spell_script: #why would this not happen?
		spell = spell_resource.spell_script.new()  # instantiate makes a node2D?
		add_child(spell)
		_did_resolve = await spell.cast(self)
	else:
		print("NO SPELL SCRIPT for ", spell_resource)
		print("with name ",spell_resource.name)
	
	var _emergency_debugging_frame_limit = 0
	while is_instance_valid(spell) and spell in get_children():
		await get_tree().process_frame
		_emergency_debugging_frame_limit += 1
		if _emergency_debugging_frame_limit > 500:
			print("ERROR::: STUCK WAITING FOR CHILD TO DIE")
	
	print("Done casting",spell_resource.name)
	if spell_resource.temporary and _did_resolve and not (items.get("strange_spoon", 0) and randf()<0.5):
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

#func unlock_random_spell():
#	var new_spell = locked_spell_resources.pick_random()
#	spell_book.append(new_spell)
#	recipe_book.append(create_random_recipe(new_spell.dance_length))

func create_random_recipe(recipe_length :int):
	var all_inputs = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.ZERO]
	var recipe: Array[Step] = []
	for i in range(recipe_length):
		recipe.append(Step.make_direction(all_inputs.pick_random()))
	if randf()<0.2:
		recipe.append(Step.make_wildcard())
	return recipe

func take_damage(amount=1):
	super(amount)
	ui_node.flash_damage()
	await get_tree().create_timer(0.1).timeout

func die():
	print(name, " died a horrible death.")
	#queue_free()
	world.units.is_running = false
	#await get_tree().create_timer(5.0).timeout


func visual_armadillo_curl():
	var direction = get_facing()
	if direction == Vector2i.UP:
		anim.play("roll_up")
	elif direction == Vector2i.DOWN:
		anim.play("roll_down")
	else:
		anim.play("roll")
