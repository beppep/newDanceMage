extends Node2D
class_name Item

@onready var world : World = $"/root/World"

#signal item_picked_up #how to connect for each new item? using coupling instead as usual lol.

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
	#get_path()
	_player.items[item_resource.dev_name] = _player.items.get(item_resource.dev_name, 0) + 1
	_player.displayed_items.append(item_resource)
	match item_resource.dev_name:
		"heart":
			_player.max_health += 1
			_player.health += 1
			_player.health_changed.emit()
		"recipe_shuffler":
			var _all_recipes = []
			for spell in _player.spell_book:
				_all_recipes.append(spell.recipe)
			_all_recipes.shuffle()
			for spell in _player.spell_book:
				spell.recipe = _all_recipes.pop_back()
			world.main_ui._on_spells_changed()
			
	#item_picked_up.emit(item_resource)
	world.main_ui._on_item_picked_up(item_resource)
	queue_free()
