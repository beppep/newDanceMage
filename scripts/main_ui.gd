extends CanvasLayer
class_name MainUI

@onready var player: Player = $"/root/World/Level/Units/Player"
@onready var health_container := $VBoxContainer/Health
@onready var spell_container := $VBoxContainer/Spells
@onready var upgrade_button := $Shop/UpgradeButton
@onready var damage_flash := $DamageFlash


@onready var spell_card_scene := preload("res://scenes/spell_card.tscn")

const SHIELD_TEXTURE := preload("res://assets/sprites/ui/shield.png")
const heart_texture := preload("res://assets/sprites/ui/heart.png")
const dark_heart_texture := preload("res://assets/sprites/ui/darkheart.png")
const arrow_texture := preload("res://assets/sprites/ui/arrow.png")
const dark_arrow_texture := preload("res://assets/sprites/ui/darkarrow.png")
const nowhere_arrow_texture := preload("res://assets/sprites/ui/dot.png")
const dark_nowhere_arrow_texture := preload("res://assets/sprites/ui/darkdot.png")
const wildcard_arrow_texture := preload("res://assets/sprites/ui/wildcard.png")
const dark_wildcard_arrow_texture := preload("res://assets/sprites/ui/darkwildcard.png")

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
	$VBoxContainer.scale = Vector2(4, 4)
	

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
	
func show_shop():
	$Shop.show()
func hide_shop():
	$Shop.hide()
	
func get_shop_is_shown() -> bool:
	return $Shop.visible
func get_card_reward_is_shown() -> bool:
	return $"CardRewards/Cards".get_child_count() > 0

func _on_health_changed():
	for child in health_container.get_children():
		child.queue_free()
	for i in range(player.max_health):
		var heart = TextureRect.new()
		heart.texture = heart_texture if i < player.health else dark_heart_texture
		heart.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		health_container.add_child(heart)
	if player.shield:
		var shield = TextureRect.new()
		shield.texture = SHIELD_TEXTURE
		shield.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		shield.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		health_container.add_child(shield)

func _on_spells_changed(shop_version = false):
	"""
	This method draws the arrows of the spells to show the dancing progress.
	If shopversion == true, it instead lights up only the selected arrow for upgrading.
	"""
	for child in spell_container.get_children():
		child.queue_free()
	
	$CoinLabel.text = str(player.coins)+"$"

	
	for i in range(player.spell_book.size()):
		var spell_HBox = HBoxContainer.new()
		spell_container.add_child(spell_HBox)
		
		var spell_icon = TextureButton.new()
		spell_icon.texture_normal = player.spell_book[i].image
		#spell_icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		#spell_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
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
	$"Shop/UpgradeButton/VBoxContainer/cost".text = str(cost) + "$"
	$"Shop/UpgradeButton2/VBoxContainer/cost".text = str(cost) + "$"
	

func flash_icon(node: Node):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(1.2, 1.2), 0.08).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "modulate", Color(1.2, 1.2, 1.2), 0.05)
	tween.tween_property(node, "scale", Vector2(1, 1), 0.1)
	tween.tween_property(node, "modulate", Color(1,1,1), 0.05)


func _on_upgrade_button_pressed() -> void:
	if selected_spell_in_shop!=null and selected_arrow_in_shop!=null:
		var spell = player.spell_book[selected_spell_in_shop]
		var cost = UPGRADE_COST + UPGRADE_SCALING * spell.upgrade_count
		if player.coins >= cost and len(player.spell_book[selected_spell_in_shop].recipe)>1:
			player.coins -= cost
			spell.recipe.pop_at(selected_arrow_in_shop)
			spell.upgrade_count+=1
			_on_spells_changed()
			_on_health_changed()


func _on_upgrade_button_2_pressed() -> void:
	if selected_spell_in_shop!=null and selected_arrow_in_shop!=null:
		var spell = player.spell_book[selected_spell_in_shop]
		var cost = UPGRADE_COST + UPGRADE_SCALING * spell.upgrade_count
		if player.coins >= cost:
			player.coins -= cost
			spell.recipe[selected_arrow_in_shop] = Step.make_wildcard()
			spell.upgrade_count+=1
			_on_spells_changed()
			_on_health_changed()
			



func flash_damage():
	damage_flash.visible = true
	damage_flash.modulate.a = 1

	var tween := create_tween()
	tween.tween_property(damage_flash, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func():damage_flash.visible = false)
