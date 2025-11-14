extends Unit

func _process(_delta: float) -> void:
	if world.units.get_unit_at(location + Vector2i(0,1)) == world.player:
		world.get_node("MainUI").show_shop()
	else:
		world.get_node("MainUI").hide_shop()


func die():
	$AnimatedSprite2D.play("dead")
