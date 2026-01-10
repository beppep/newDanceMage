extends Node2D
class_name Item

@onready var world : World = $"/root/World"

var item_resource : ItemResource
var tween: Tween
@onready var location := World.pos_to_loc(position): # duplicated code. use inheritance?
	set(loc):
		location = loc
		if is_instance_valid(tween) and tween.is_running():
			await tween.finished
		var new_position = World.loc_to_pos(loc)
		tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "position", new_position, 0.1)




func pick_up(_player : Player):
	get_path()
	_player.items[item_resource.dev_name] = _player.items.get(item_resource.dev_name, 0) + 1
	match item_resource.dev_name:
		"heart":
			_player.max_health += 1
			_player.health += 1
	queue_free()
