extends Unit

@onready var world = $"/root/World"


func die():
	super()
	world.player.unlock_random_spell()
