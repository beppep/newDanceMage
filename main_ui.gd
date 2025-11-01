extends CanvasLayer

@onready var player: Player = $"/root/World/Units/Player"
@onready var health_container := $VBoxContainer/Health
@onready var spell_container := $VBoxContainer/Spells

@onready var spell_card_scene := preload("res://scenes/spell_card.tscn")

@onready var heart_texture := preload("res://assets/sprites/ui/heart.png")
@onready var dark_heart_texture := preload("res://assets/sprites/ui/darkheart.png")
@onready var arrow_texture := preload("res://assets/sprites/ui/arrow.png")
@onready var dark_arrow_texture := preload("res://assets/sprites/ui/darkarrow.png")
@onready var nowhere_arrow_texture := preload("res://assets/sprites/ui/dot.png")
@onready var dark_nowhere_arrow_texture := preload("res://assets/sprites/ui/darkdot.png")

var arrow_textures
var dark_arrow_textures


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
		

func _on_health_changed():
	for child in health_container.get_children():
		child.queue_free()
	for i in range(player.max_health):
		var heart = TextureRect.new()
		heart.texture = heart_texture if i < player.health else dark_heart_texture
		heart.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		health_container.add_child(heart)

func _on_spells_changed():
	for child in spell_container.get_children():
		child.queue_free()
	
	for i in range(player.spell_book.size()):
		var spell_HBox = HBoxContainer.new()
		spell_container.add_child(spell_HBox)
		
		var spell_icon = TextureRect.new()
		spell_icon.texture = player.spell_book[i].image
		#spell_icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		#spell_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		spell_HBox.add_child(spell_icon)
		
		var alignment = player.check_recipe_alignment(player.recipe_book[i])
		
		for x in range(player.recipe_book[i].size()):
			var arrow_vector = player.recipe_book[i][x]
			var arrow = TextureRect.new()
			if arrow_vector == Vector2i.ZERO:
				arrow.texture = nowhere_arrow_texture if x < alignment else dark_nowhere_arrow_texture
			else:
				arrow.texture = arrow_textures[rad_to_deg(Vector2(arrow_vector).angle())/90] if x < alignment else dark_arrow_textures[rad_to_deg(Vector2(arrow_vector).angle())/90]
			arrow.expand_mode = TextureRect.EXPAND_KEEP_SIZE
			arrow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			spell_HBox.add_child(arrow)
