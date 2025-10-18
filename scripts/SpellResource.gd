# SpellResource.gd
extends Resource
class_name SpellResource
@export_category("Spells")

# --- Basic spell data ---
@export var name: String = "Some Cool Spell"
@export var dance_length: int = 4

# --- Visual effect scene (particles, etc.) ---
@export var effect_scene: PackedScene
