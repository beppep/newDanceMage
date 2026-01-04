extends Control


const ALL_CHARACTERS : Array[CharacterResource] = [
	preload("res://assets/resources/characters/wizard.tres"),
	preload("res://assets/resources/characters/rogue.tres"),
	preload("res://assets/resources/characters/armadillo.tres"),
]

@onready var character_texture : TextureRect = $"BackgroundTexture/CharacterTexture"
@onready var name_label : Label = $"BackgroundTexture/Name"

var selected_character_nr := 0


func _on_right_button_pressed(d: int) -> void:
	selected_character_nr = clamp(selected_character_nr + d, 0, len(ALL_CHARACTERS)-1)
	
	character_texture.texture = ALL_CHARACTERS[selected_character_nr].image
	name_label.text = ALL_CHARACTERS[selected_character_nr].name


func _on_start_button_pressed() -> void:
	Globals.selected_character = ALL_CHARACTERS[selected_character_nr]
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
	
