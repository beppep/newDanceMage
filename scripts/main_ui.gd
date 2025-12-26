extends CanvasLayer
class_name MainUI

@onready var player: Player = $"/root/World/Level/Units/Player"
@onready var health_container := $VBoxContainer/Health
@onready var spell_container := $VBoxContainer/Spells
@onready var upgrade_button := $Shop/UpgradeButton

@onready var spell_card_scene := preload("res://scenes/spell_card.tscn")

@onready var heart_texture := preload("res://assets/sprites/ui/heart.png")
@onready var dark_heart_texture := preload("res://assets/sprites/ui/darkheart.png")
@onready var arrow_texture := preload("res://assets/sprites/ui/arrow.png")
@onready var dark_arrow_texture := preload("res://assets/sprites/ui/darkarrow.png")
@onready var nowhere_arrow_texture := preload("res://assets/sprites/ui/dot.png")
@onready var dark_nowhere_arrow_texture := preload("res://assets/sprites/ui/darkdot.png")
@onready var wildcard_arrow_texture := preload("res://assets/sprites/ui/wildcard.png")
@onready var dark_wildcard_arrow_texture := preload("res://assets/sprites/ui/darkwildcard.png")

var arrow_textures
var dark_arrow_textures

var upgrade_cost = 1
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
	#$CardRewards.visible = true
	for i in range(spells.size()):
		var spell_card : Spell_card = spell_card_scene.instantiate()
		spell_card.spell = spells[i]
		$CardRewards.add_child(spell_card)
		spell_card.recipe = recipes[i]

func remove_card_rewards():
	for child in $CardRewards.get_children():
		child.queue_free()
	
func show_shop():
	$Shop.show()
func hide_shop():
	$Shop.hide()
	
func get_shop_is_shown() -> bool:
	return $Shop.visible
func get_card_reward_is_shown() -> bool:
	return $CardRewards.get_child_count() > 0

func _on_health_changed():
	for child in health_container.get_children():
		child.queue_free()
	for i in range(player.max_health):
		var heart = TextureRect.new()
		heart.texture = heart_texture if i < player.health else dark_heart_texture
		heart.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		health_container.add_child(heart)

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
		
		var alignment = player.check_recipe_alignment(player.recipe_book[i])
		
		for x in range(player.recipe_book[i].size()):
			var arrow_vector = player.recipe_book[i][x]
			var arrow = TextureButton.new()
			var texture_is_light: bool
			
			# select arrow lightness
			if not shop_version: # using alignment
				texture_is_light = (x < alignment)
			else: # according to shop selection
				texture_is_light = (selected_spell_in_shop == i and selected_arrow_in_shop == x)
			
			# select arrow type
			if arrow_vector == Vector2i.ZERO:
				arrow.texture_normal = nowhere_arrow_texture if texture_is_light else dark_nowhere_arrow_texture
			elif arrow_vector == null:
				arrow.texture_normal = wildcard_arrow_texture if texture_is_light else dark_wildcard_arrow_texture
			else:
				arrow.texture_normal = arrow_textures[rad_to_deg(Vector2(arrow_vector).angle())/90] if texture_is_light else dark_arrow_textures[rad_to_deg(Vector2(arrow_vector).angle())/90]
			
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
		
		tmp = player.recipe_book[spell_nr]
		player.recipe_book[spell_nr] = player.recipe_book[spell_nr-1]
		player.recipe_book[spell_nr-1] = tmp
		
		tmp = player.upgrade_count_book[spell_nr]
		player.upgrade_count_book[spell_nr] = player.upgrade_count_book[spell_nr-1]
		player.upgrade_count_book[spell_nr-1] = tmp
	
func _on_arrow_icon_pressed(spell_nr, arrow_nr): # select an arrow in the shop
	selected_spell_in_shop = spell_nr
	selected_arrow_in_shop = arrow_nr
	_on_spells_changed(true)

func flash_icon(node: Node):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(1.2, 1.2), 0.08).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "modulate", Color(1.2, 1.2, 1.2), 0.05)
	tween.tween_property(node, "scale", Vector2(1, 1), 0.1)
	tween.tween_property(node, "modulate", Color(1,1,1), 0.05)


func _on_upgrade_button_pressed() -> void:
	print( player.coins, "  ", upgrade_cost, " h ", player.upgrade_count_book[selected_spell_in_shop])
	if player.coins >= upgrade_cost and player.upgrade_count_book[selected_spell_in_shop]==0 and len(player.recipe_book[selected_spell_in_shop])>1:
		player.coins -= upgrade_cost
		player.recipe_book[selected_spell_in_shop].pop_at(selected_arrow_in_shop)
		player.upgrade_count_book[selected_spell_in_shop]+=1
		_on_spells_changed()
		_on_health_changed()
	
	
func old_rng_upgrade_code():
	if player.coins >= upgrade_cost:
		var possible_upgrades = []
		for i in range(len(player.spell_book)):
			if len(player.recipe_book[i])>1 and player.upgrade_count_book[i]==0:
				possible_upgrades.append(i)
		if possible_upgrades:
			player.coins -= upgrade_cost
			var upgraded_i = possible_upgrades.pick_random()
			var removed_arrow = randi() % player.recipe_book[upgraded_i].size()
			player.recipe_book[upgraded_i].pop_at(removed_arrow)
			player.upgrade_count_book[upgraded_i]+=1
			_on_spells_changed()
			_on_health_changed()
	


func _on_upgrade_button_2_pressed() -> void:
	if player.coins >= upgrade_cost and player.upgrade_count_book[selected_spell_in_shop]==0:
		player.coins -= upgrade_cost
		player.recipe_book[selected_spell_in_shop][selected_arrow_in_shop] = null # wildcard
		player.upgrade_count_book[selected_spell_in_shop]+=1
		_on_spells_changed()
		_on_health_changed()
	

func old_rng_upgrade_code_2() -> void:
	if player.coins >= upgrade_cost:
		var possible_upgrades = []
		for i in range(len(player.spell_book)):
			if len(player.recipe_book[i])>1 and player.upgrade_count_book[i]==0:
				possible_upgrades.append(i)
		if possible_upgrades:
			player.coins -= upgrade_cost
			var upgraded_i = possible_upgrades.pick_random()
			var transformed_arrow = randi() % player.recipe_book[upgraded_i].size()
			player.recipe_book[upgraded_i][transformed_arrow] = null # wildcard
			player.upgrade_count_book[upgraded_i]+=1
			_on_spells_changed()
			_on_health_changed()
