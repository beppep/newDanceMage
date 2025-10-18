extends Node

@onready var units = $Units
@onready var player = units.get_node("Player")

var state := "player_movement"  # can be "player_movement", "spellcasting", "enemy??"


func start_player_turn():
	state = "player_movement"
	print("Player's turn!")
	player.start_turn()

func _process(_delta):
	# Wait until player finishes turn, then switch
	if state == "player_movement" and player.phase == player.Phase.NOT_MY_TURN:
		start_player_turn()


func start_enemy_turn():
	state = "enemy"
	print("Enemies' turn!")
	await run_enemy_turns()
	start_player_turn()


func run_enemy_turns():
	for unit in units.get_children():
		if not is_instance_valid(unit):
			continue
		#await unit.take_turn()
