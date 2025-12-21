extends Node

func delay(seconds: float) -> Signal:
	return get_tree().create_timer(seconds).timeout

func delay_frames(frames: int):
	for i in range(frames):
		await get_tree().process_frame
