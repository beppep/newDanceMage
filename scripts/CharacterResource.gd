extends Resource
class_name CharacterResource
@export_category("Character")

@export var name: String = "Some Cool Spell"
@export var image: Texture2D
@export var description: String = "Some cool spell does something cool"
@export var starting_spell: SpellResource
@export var starting_dance: Array[Step]


# HAVE TO FIND A WAY TO REPRESENT WILDCARDS INSTEAD OF NULL!!!
