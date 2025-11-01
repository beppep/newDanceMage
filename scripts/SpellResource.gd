# SpellResource.gd
extends Resource
class_name SpellResource
@export_category("Spells")

# --- Basic spell data ---
@export var name: String = "Some Cool Spell"
@export var image: Texture2D
@export var description: String = "Some cool spell does something cool"
@export var dance_length: int = 4

# --- Visual effect scene (particles, etc.) ---
@export var spell_script: Script
