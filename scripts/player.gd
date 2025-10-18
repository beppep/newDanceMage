extends Unit

@onready var anim = $AnimatedSprite2D
@onready var units = get_parent()

var fireball_spell = preload("res://assets/resources/spells/fireball_spell.tres")

const TILE_SIZE = 16
const MOVE_FRAMES = 8  # time it takes to move one step

enum Phase { AWAIT_INPUT, MOVING, CAST_NEXT_SPELL, AWAIT_SPELL_END, NOT_MY_TURN }

var phase := Phase.NOT_MY_TURN
var move: Vector2 = Vector2.ZERO
var move_frames_remaining: = 0
var move_history: Array = []  # stores Vector2 positions
var recipe_book = [[Vector2i.UP, Vector2i.DOWN], ]
var spell_book = [fireball_spell, ]
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
			position += move * TILE_SIZE / MOVE_FRAMES
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
				
		

func _await_move_input():
	var got_input = true
	if Input.is_action_just_pressed("move_up"):
		move = Vector2.UP
		anim.play("up")
	elif Input.is_action_just_pressed("move_down"):
		move = Vector2.DOWN
		anim.play("down")
	elif Input.is_action_just_pressed("move_left"):
		move = Vector2.LEFT
		anim.play("right") # flip when walking left
		anim.flip_h = true
	elif Input.is_action_just_pressed("move_right"):
		move = Vector2.RIGHT
		anim.play("right")
		anim.flip_h = false
	else:
		got_input = false
	
	if got_input:
		move_history.append(Vector2i(move))
		if can_move_to(move * TILE_SIZE + position):
			move_frames_remaining = MOVE_FRAMES
			phase = Phase.MOVING



func check_recipe(recipe):
	if move_history.slice(-recipe.size(), move_history.size()) == recipe:
		return true
	else:
		return false

func cast_spell(spell_resource: SpellResource):
	if spell_resource.spell_script:
		var spell = spell_resource.spell_script.new(self)
		#spell.caster = self
		spell.cast()


func end_turn():
	pass
