extends AnimatedSprite3D

@onready var mon : Monigote = get_parent()

func _ready():
	material_override.set_shader_parameter("outline_color", get_parent().player.color)

func _process(_delta):
	material_override.set_shader_parameter("spriteTexture", sprite_frames.get_frame_texture(animation, frame))
	material_override.set_shader_parameter("modulate", modulate)
	
	#rotation.x = get_viewport().get_camera_3d().rotation.x
	
	modulate = Color.WHITE
	if mon.invincible and not mon.grabbed:
		modulate.a = .7
	elif mon.stunned:
		modulate = Color.GRAY
	else:
		modulate.a = 1

	# Si el monigote está pausado no hay animaciones
	if not mon.is_processing():
		modulate = Color.WHITE
		play("Idle")
		return

	if not mon._movementDir.is_zero_approx():
		match vecTo4Dir(mon._movementDir):
			Cardinal.E: play("RunningRight")
			Cardinal.W: play("RunningLeft")
			Cardinal.S: play("RunningDown")
			Cardinal.N: play("RunningUp")
	else:
		play("Idle")

	if not mon.unclampedVelocity.is_zero_approx():
		play("Pushed")
		frame = vecTo8Dir(mon.unclampedVelocity)
	
	if mon.grabbing:
		play("Grabbing")
		frame = vecTo8Dir(mon.grabDir)

enum Cardinal {E, NE, N, NW, W, SW, S, SE}

## Saca ángulos de la forma normal (desde 0 hasta 2PI), Godot lo hace de una manera rara
func normalAngle(vector : Vector2) -> float:
	var angle = -vector.angle()
	if angle < 0:
		angle += 2*PI
	return angle

func vecTo8Dir(vector : Vector2) -> Cardinal:
	var angle = normalAngle(vector)
	angle += PI/8
	return floor( angle / (PI/4) )

func vecTo4Dir(vector : Vector2) -> Cardinal:
	var angle = normalAngle(vector)
	if angle > 7*PI/4 or angle < PI/4:
		return Cardinal.E
	elif angle > PI/4 and angle < 3*PI/4:
		return Cardinal.N
	elif angle > 3*PI/4 and angle < 5*PI/4:
		return Cardinal.W
	return Cardinal.S
