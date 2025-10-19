extends CanvasLayer

@onready var player: Player = $"/root/World/Units/Player"
@onready var health_container := $Health
@onready var heart_texture := preload("res://assets/sprites/ui/heart.png")
@onready var dark_heart_texture := preload("res://assets/sprites/ui/darkheart.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.health_changed.connect(_on_health_changed)
	_on_health_changed()

func _on_health_changed():
	for child in health_container.get_children():
		child.queue_free()
	for i in range(player.max_health):
		var heart = TextureRect.new()
		heart.texture = heart_texture if i < player.health else dark_heart_texture
		heart.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		health_container.add_child(heart)
