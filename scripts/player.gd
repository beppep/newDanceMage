extends Unit


var fireball_spell = preload("res://assets/resources/spells/fireball_spell.tres")
var wind_spell = preload("res://assets/resources/spells/wind_spell.tres")


var move_history: Array = []  # stores Vector2 positions
var recipe_book = [[Vector2i.UP, Vector2i.DOWN], [Vector2i.UP, Vector2i.UP],]
var spell_book = [fireball_spell, wind_spell]
var current_spell_nr = 0

func start_turn():
	phase = Phase.AWAIT_INPUT

func _physics_process(_delta): # called at 60 fps
	match phase:
		Phase.NOT_MY_TURN:
			return
		
		Phase.AWAIT_INPUT:
			_await_move_input()
		
		Phase.MOVING:
			position += move_dir * TILE_SIZE / MOVE_FRAMES
			move_frames_remaining -= 1
			if move_frames_remaining == 0:
				phase = Phase.CAST_NEXT_SPELL
				current_spell_nr = 0
		
		Phase.CAST_NEXT_SPELL:
			while current_spell_nr < spell_book.size():
				if check_recipe(recipe_book[current_spell_nr]):
					cast_spell(spell_book[current_spell_nr])
					phase = Phase.AWAIT_SPELL_END
					break
				current_spell_nr += 1
			phase = Phase.NOT_MY_TURN
		
		Phase.AWAIT_SPELL_END:
			if get_children().size() == 1:
				phase = Phase.NOT_MY_TURN
		

func _await_move_input():
	var got_input = true
	if Input.is_action_just_pressed("move_up"):
		move_dir = Vector2.UP
		anim.play("up")
	elif Input.is_action_just_pressed("move_down"):
		move_dir = Vector2.DOWN
		anim.play("down")
	elif Input.is_action_just_pressed("move_left"):
		move_dir = Vector2.LEFT
		anim.play("right") # flip when walking left
		anim.flip_h = true
	elif Input.is_action_just_pressed("move_right"):
		move_dir = Vector2.RIGHT
		anim.play("right")
		anim.flip_h = false
	else:
		got_input = false
	
	if got_input:
		move_history.append(Vector2i(move_dir))
		if is_empty(move_dir * TILE_SIZE + position):
			move_frames_remaining = MOVE_FRAMES
			phase = Phase.MOVING



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
