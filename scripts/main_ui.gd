extends CanvasLayer
class_name MainUI

@onready var world: World = $"/root/World"
@onready var player: Player = $"/root/World/Level/Units/Player"
@onready var health_container := $VBoxContainer/Health
@onready var spell_container := $VBoxContainer/Spells
@onready var item_container := $Items
@onready var damage_flash := $DamageFlash
@onready var pickup_info = $PickupInfo
@onready var spell_flash = $SpellFlash


@onready var spell_card_scene := preload("res://scenes/spell_card.tscn")
@onready var item_card_scene := preload("res://scenes/item_card.tscn")

const SHIELD_TEXTURE := preload("res://assets/sprites/ui/shield.png")
const heart_texture := preload("res://assets/sprites/ui/heart.png")
const dark_heart_texture := preload("res://assets/sprites/ui/darkheart.png")
const arrow_texture := preload("res://assets/sprites/ui/arrow.png")
const dark_arrow_texture := preload("res://assets/sprites/ui/darkarrow.png")
const nowhere_arrow_texture := preload("res://assets/sprites/ui/dot.png")
const dark_nowhere_arrow_texture := preload("res://assets/sprites/ui/darkdot.png")
const wildcard_arrow_texture := preload("res://assets/sprites/ui/wildcard.png")
const dark_wildcard_arrow_texture := preload("res://assets/sprites/ui/darkwildcard.png")

const UI_TILE_SIZE = 64

var arrow_textures
var dark_arrow_textures

const UPGRADE_COST = 1
const UPGRADE_SCALING = 1
var selected_spell_in_shop = null
var selected_arrow_in_shop = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	arrow_textures = [arrow_texture]
	dark_arrow_textures = [dark_arrow_texture]
	player.health_changed.connect(_on_health_changed)
	
	# no way this is the easiest way to rotate ui lul
	for i in range(3):
		var tex = arrow_textures[-1].get_image()
		tex.rotate_90(0)
		var rotated_texture = ImageTexture.create_from_image(tex)
		arrow_textures.append(rotated_texture)
	for i in range(3):
		var tex = dark_arrow_textures[-1].get_image()
		tex.rotate_90(0)
		var rotated_texture = ImageTexture.create_from_image(tex)
		dark_arrow_textures.append(rotated_texture)
	
	
	_on_health_changed()
	_on_spells_changed()
	#$VBoxContainer.scale = Vector2(4, 4)
	#item_container.scale = Vector2(4, 4)
	

func show_card_reward(spells, recipes):
	$CardRewards.visible = true
	for i in range(spells.size()):
		var spell_card : Spell_card = spell_card_scene.instantiate()
		spell_card.spell = spells[i]
		$"CardRewards/Cards".add_child(spell_card)
		spell_card.recipe = recipes[i]

func remove_card_rewards():
	$CardRewards.visible = false
	for child in $"CardRewards/Cards".get_children():
		child.queue_free()
	
func show_upgrade_shop():
	$UpgradeShop.show()
func hide_upgrade_shop():
	$UpgradeShop.hide()
func show_item_shop(items_for_sale : Array[ItemResource]):
	if $ItemShop.visible == false:
		for i in range(items_for_sale.size()):
			var item_card : Item_card = item_card_scene.instantiate()
			item_card.item = items_for_sale[i]
			$"ItemShop".add_child(item_card)
		$ItemShop.show()
func hide_item_shop():
	$ItemShop.hide()
	for child in $"ItemShop".get_children():
		child.queue_free()
	
	
func get_shop_is_shown() -> bool:
	return $ItemShop.visible or $UpgradeShop.visible
func get_card_reward_is_shown() -> bool:
	return $"CardRewards/Cards".get_child_count() > 0

func _on_health_changed():
	for child in health_container.get_children():
		child.queue_free()
	for i in range(player.max_health):
		var heart = TextureRect.new()
		heart.texture = heart_texture if i < player.health else dark_heart_texture
		heart.custom_minimum_size = Vector2i(UI_TILE_SIZE,UI_TILE_SIZE)
		health_container.add_child(heart)
	if player.shield:
		var shield = TextureRect.new()
		shield.texture = SHIELD_TEXTURE
		shield.custom_minimum_size = Vector2i(UI_TILE_SIZE,UI_TILE_SIZE)
		health_container.add_child(shield)

func _on_items_changed():
	for child in item_container.get_children():
		child.queue_free()
	for item_res in player.displayed_items:
		var item = TextureRect.new()
		item.texture = item_res.image
		item.custom_minimum_size = Vector2i(UI_TILE_SIZE,UI_TILE_SIZE)
		item_container.add_child(item)

func _on_spells_changed(shop_version = false):
	"""
	This method draws the arrows of the spells to show the dancing progress.
	If shopversion == true, it instead lights up only the selected arrow for upgrading.
	"""
	for child in spell_container.get_children():
		child.queue_free()
	
	$CoinLabel.text = str(player.diamonds)+"$, Floor: " + str(world.current_floor)

	
	for i in range(player.spell_book.size()):
		var spell_HBox = HBoxContainer.new()
		spell_container.add_child(spell_HBox)
		
		var spell_icon = TextureButton.new()
		spell_icon.texture_normal = player.spell_book[i].image
		spell_icon.custom_minimum_size = Vector2i(UI_TILE_SIZE,UI_TILE_SIZE)
		spell_icon.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		spell_HBox.add_child(spell_icon)
		
		var alignment = player.check_recipe_alignment(player.spell_book[i])
		
		for x in range(player.spell_book[i].recipe.size()):
			var step : Step = player.spell_book[i].recipe[x]
			var arrow = TextureButton.new()
			var texture_is_light: bool
			
			# select arrow lightness
			if not shop_version: # using alignment
				texture_is_light = (x < alignment)
			else: # according to shop selection
				texture_is_light = (selected_spell_in_shop == i and selected_arrow_in_shop == x)
			
			# select arrow texture
			if step.kind == Step.Kind.WILDCARD:
				arrow.texture_normal = wildcard_arrow_texture if texture_is_light else dark_wildcard_arrow_texture
			elif step.direction == Vector2i.ZERO:
				arrow.texture_normal = nowhere_arrow_texture if texture_is_light else dark_nowhere_arrow_texture
			else:
				var _index = rad_to_deg(Vector2(step.direction).angle())/90
				arrow.texture_normal = arrow_textures[_index] if texture_is_light else dark_arrow_textures[_index]
			
			if x==alignment-1 and not shop_version:
				flash_icon(arrow)
			arrow.custom_minimum_size = Vector2i(UI_TILE_SIZE,UI_TILE_SIZE)
			arrow.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			spell_HBox.add_child(arrow)
			arrow.pressed.connect(_on_arrow_icon_pressed.bind(i, x))
		spell_icon.pressed.connect(_on_spell_icon_pressed.bind(i))

func _on_spell_icon_pressed(spell_nr): # swap two spells in the order
	if spell_nr > 0:
		var tmp = player.spell_book[spell_nr]
		player.spell_book[spell_nr] = player.spell_book[spell_nr-1]
		player.spell_book[spell_nr-1] = tmp
	
func _on_arrow_icon_pressed(spell_nr, arrow_nr): # select an arrow in the shop
	selected_spell_in_shop = spell_nr
	selected_arrow_in_shop = arrow_nr
	_on_prices_changed()
	_on_spells_changed(true)

func _on_prices_changed():
	var spell = player.spell_book[selected_spell_in_shop]
	var cost = UPGRADE_COST + UPGRADE_SCALING * spell.upgrade_count
	$"UpgradeShop/UpgradeButton/VBoxContainer/cost".text = str(cost) + "$"
	$"UpgradeShop/UpgradeButton2/VBoxContainer/cost".text = str(cost) + "$"
	

func flash_icon(node: Node):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(1.2, 1.2), 0.08).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "modulate", Color(1.2, 1.2, 1.2), 0.05)
	tween.tween_property(node, "scale", Vector2(1, 1), 0.1)
	tween.tween_property(node, "modulate", Color(1,1,1), 0.05)

func flash_spell(spell_resource : SpellResource):
	var node : TextureRect = spell_flash.get_node("TextureRect")
	node.texture = spell_resource.image
	node.position = Vector2(0,0)
	node.scale = Vector2(4,4)
	node.modulate.a = 1.0
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tween = get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(16, 16), 0.3)
	tween.parallel().tween_property(node, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(node,"position",node.position - Vector2(16,16)*16 * 0.5, 0.3)
	

func _on_upgrade_button_pressed() -> void:
	if selected_spell_in_shop!=null and selected_arrow_in_shop!=null:
		var spell = player.spell_book[selected_spell_in_shop]
		var cost = UPGRADE_COST + UPGRADE_SCALING * spell.upgrade_count
		if player.diamonds >= cost and len(player.spell_book[selected_spell_in_shop].recipe)>1:
			player.diamonds -= cost
			spell.recipe.pop_at(selected_arrow_in_shop)
			spell.upgrade_count+=1
			_on_spells_changed()
			_on_health_changed()


func _on_upgrade_button_2_pressed() -> void:
	if selected_spell_in_shop!=null and selected_arrow_in_shop!=null:
		var spell = player.spell_book[selected_spell_in_shop]
		var cost = UPGRADE_COST + UPGRADE_SCALING * spell.upgrade_count
		if player.diamonds >= cost:
			player.diamonds -= cost
			spell.recipe[selected_arrow_in_shop] = Step.make_wildcard()
			spell.upgrade_count+=1
			_on_spells_changed()
			_on_health_changed()
			

func _on_item_picked_up(item_resource : ItemResource):
	pickup_info.get_node("PickupName").text = item_resource.name
	pickup_info.get_node("PickupDescription").text = item_resource.description
	pickup_info.show()
	_on_items_changed()

func flash_damage():
	damage_flash.visible = true
	damage_flash.modulate.a = 1

	var tween := create_tween()
	tween.tween_property(damage_flash, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func():damage_flash.visible = false)
