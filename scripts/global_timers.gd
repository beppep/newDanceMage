extends Node

func delay(seconds: float) -> Signal:
	return get_tree().create_timer(seconds).timeout
