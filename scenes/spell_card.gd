extends Control
class_name Spell_card

@onready var world : World = get_tree().current_scene


@onready var arrow_texture := preload("res://assets/sprites/ui/arrow.png")
@onready var dark_arrow_texture := preload("res://assets/sprites/ui/darkarrow.png")
@onready var nowhere_arrow_texture := preload("res://assets/sprites/ui/dot.png")
@onready var dark_nowhere_arrow_texture := preload("res://assets/sprites/ui/darkdot.png")

var arrow_textures
var dark_arrow_textures
	
@export var spell: SpellResource:
	set(value):
		spell = value
		$Button/VBoxContainer/title.text = spell.name
		$Button/VBoxContainer/description.text = spell.description
		$Button/VBoxContainer/TextureRect.texture = spell.image

@export var recipe: Array:
	set(value):
		recipe = value
		for x in range(recipe.size()):
			var arrow_vector = recipe[x]
			var arrow := TextureRect.new()
			if arrow_vector == Vector2i.ZERO:
				arrow.texture = nowhere_arrow_texture
			else:
				arrow.texture = arrow_textures[rad_to_deg(Vector2(arrow_vector).angle())/90]
			arrow.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			arrow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			#arrow.custom_minimum_size *= 4  # 4x bigger than default (if already has min size)
			#arrow.custom_minimum_size = Vector2(arrow.texture.get_width(), arrow.texture.get_height()) * 4
			
			$Button/VBoxContainer/HBoxContainer.add_child(arrow)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	arrow_textures = [arrow_texture]
	dark_arrow_textures = [dark_arrow_texture]
	
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
		

func _on_button_pressed() -> void:
	print("yo",spell,recipe)
	world.player.unlock(spell, recipe)
	world.get_node("MainUI").remove_card_rewards()
	
