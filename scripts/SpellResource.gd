extends Resource
class_name SpellResource
@export_category("Spell")

@export var name: String = "Some Cool Spell"
@export var image: Texture2D
@export var description: String = "Some cool spell does something cool"
@export var dance_length: int = 4
@export var spell_script: Script
@export var recipe: Array[Step]
@export var temporary: bool = false
@export var upgrade_count: int = 0
