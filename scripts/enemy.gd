extends Unit

func process_turn(world: World):
	print("Processing enemy's turn...")
	turn_done.emit()
