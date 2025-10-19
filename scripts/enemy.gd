extends Unit

func process_turn(world: World):
	print('Processing enemy turn...')
	turn_done.emit()
