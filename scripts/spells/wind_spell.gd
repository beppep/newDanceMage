extends Spell

@export var projectile_scene: PackedScene = preload("res://scenes/particles/Projectile.tscn")
@onready var wall_tileset := $"/root/World/TileMapLayerWalls"


var RANGE = 10

func cast(caster: Unit):
	for direction in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		# push in reverse order
		for i in range(RANGE):
			var j = RANGE - i
			var target_cell = caster.location + direction * j
			var unit = world.units.get_unit_at(target_cell)
			if unit:
				unit.move_in_direction(direction)
				
		spawn_beam(caster.global_position, direction, 500, 16, 0.2)

	life_time = 8


func spawn_beam(pos: Vector2, direction: Vector2, length := 5000, thickness := 20, lifetime := 0.1):
	# Normalize the direction to avoid scaling issues
	direction = direction.normalized()
	
	# Create beam node
	var beam = Node2D.new()
	beam.global_position = pos
	
	# Rotate node to match direction
	beam.rotation = direction.angle()
	
	# Create Sprite2D
	var sprite = Sprite2D.new()
	beam.add_child(sprite)
	
	# White 1x1 texture
	var img = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	var tex = ImageTexture.create_from_image(img)
	sprite.texture = tex
	
	# Scale sprite to desired beam length and thickness
	sprite.scale = Vector2(length, thickness)
	sprite.centered = true  # Make beam rotate around center
	
	# Optional: shader for glow/color
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;
uniform vec4 beam_color : source_color = vec4(0.7,0.7,0.8,0.5);
uniform float softness = 0.5;
void fragment() {
	float dist = abs(UV.y-0.5);
	float beam = smoothstep(0.5, 0.5 - softness, dist);
	COLOR = beam_color * beam;
}
"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	sprite.material = mat
	
	# Add to current scene
	get_tree().current_scene.add_child(beam)
	
	# Remove after lifetime
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = lifetime
	beam.add_child(timer)
	timer.start()
	timer.timeout.connect(Callable(beam, "queue_free"))
