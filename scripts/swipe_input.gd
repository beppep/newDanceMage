extends Node

var start_pos := Vector2.ZERO
var min_swipe_dist := 40.0

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			start_pos = event.position
		else:
			_handle_swipe(event.position)
			
func _handle_swipe(end_pos):
	
	var delta = end_pos - start_pos
	
	if delta.length() < min_swipe_dist:
		Input.action_press("move_nowhere")
		Input.action_release("move_nowhere")
	elif abs(delta.x) > abs(delta.y):
		if delta.x > 0:
			Input.action_press("move_right")
			Input.action_release("move_right")
		else:
			Input.action_press("move_left")
			Input.action_release("move_left")
	else:
		if delta.y > 0:
			Input.action_press("move_down")
			Input.action_release("move_down")
		else:
			Input.action_press("move_up")
			Input.action_release("move_up")
