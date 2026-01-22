extends Unit


var is_upgrade_trader : bool
var items_for_sale : Array[ItemResource] = []
@onready var main_ui : MainUI = world.get_node("MainUI")

func _ready():
	super()
	is_upgrade_trader = (randf() < 0.5)
	if not is_upgrade_trader:
		generate_item_cards()

func generate_item_cards():
	for i in range(3):
		var new_item : ItemResource = Items.choose_random_item() #.duplicate()?
		items_for_sale.append(new_item)

func _process(_delta: float) -> void:
	if world.units.get_unit_at(location + Vector2i(0,1)) == world.player:
		if is_upgrade_trader:
			main_ui.show_upgrade_shop()
		else:
			main_ui.show_item_shop(items_for_sale)
	else:
		if is_upgrade_trader:
			main_ui.hide_upgrade_shop()
		else:
			main_ui.hide_item_shop() # what if there is 2 item shops?


func die():
	$AnimatedSprite2D.play("dead")
	#maybe should die after like 10 hits?
