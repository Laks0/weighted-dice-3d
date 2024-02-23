extends AnimatedSprite3D

func _ready():
	material_override.set_shader_parameter("outline_color", get_parent().player.color)

func _process(_delta):
	material_override.set_shader_parameter("spriteTexture", sprite_frames.get_frame_texture(animation, frame))
	material_override.set_shader_parameter("modulate", modulate)
