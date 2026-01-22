extends Node2D
class_name Item

@onready var world : World = $"/root/World"


var item_resource : ItemResource
var tween: Tween
@onready var location := World.pos_to_loc(position): # duplicated code. use composition?
	set(loc):
		location = loc
		if is_instance_valid(tween) and tween.is_running():
			await tween.finished
		var new_position = World.loc_to_pos(loc)
		tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "position", new_position, 0.1)



func pick_up(_player : Player):
	item_resource.pick_up_effects(_player, world)
	#world.main_ui._on_item_picked_up(item_resource) # should it happen only here or also in shop^?
	queue_free()
