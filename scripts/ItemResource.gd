extends Resource
class_name ItemResource

@export_category("Item")

@export var name: String = "Some Cool Display Name"
@export var dev_name: String = "item_123"
@export var image: Texture2D
@export var description: String = "Does something cool"
@export var price: int = 4
@export var stackable = false


func pick_up_effects(_player : Player, world : World):
	_player.items[dev_name] = _player.items.get(dev_name, 0) + 1
	_player.displayed_items.append(self)
	match dev_name:
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
	world.main_ui._on_item_picked_up(self) # should it happen in shop or only in item.pick_up?
