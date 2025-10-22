extends Unit


@export var jellyfish_scene: PackedScene = preload("res://scenes/enemies/ghost.tscn")


func die():
	super()
	var jellyfish = jellyfish_scene.instantiate()
	jellyfish.position = position
	world.units.add_child(jellyfish)
	
