extends AnimatedSprite3D

var onArena := false

@export var mon : Monigote

@export var crownTexture : Texture
@export var jokerHatTexture : Texture

@export var betSignalScale : int = 4

func _ready():
	material_override.set_shader_parameter("outline_color", mon.player.color)

func arenaReady():
	onArena = true
	var currentBet : Bet = BetHandler.currentBet
	
	########################
	# Señalizador de apuesta
	########################
	match currentBet.monigoteSignal:
		Bet.MonigoteSignal.CROWN: $BetSignalSprite.texture = crownTexture
		Bet.MonigoteSignal.JOKER_HAT: $BetSignalSprite.texture = jokerHatTexture

var hasSignal := false

func _process(_delta):
	material_override.set_shader_parameter("spriteTexture", sprite_frames.get_frame_texture(animation, frame))
	material_override.set_shader_parameter("modulate", modulate)
	
	rotation.x = get_viewport().get_camera_3d().rotation.x
	
	modulate = mon.color
	if mon.invincible and not mon.grabbed:
		modulate.a = .7
	elif mon.stunned:
		modulate = Color.GRAY
	else:
		modulate.a = 1
	
	#############
	# Animaciones
	#############
	
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
	
	########################
	# Señalizador de apuesta
	########################
	if not onArena:
		return
	
	if BetHandler.currentBet.monigoteSignal == Bet.MonigoteSignal.NONE:
		return
	var signalVisible := false
	if BetHandler.getCandidateScore(mon.player.id) == BetHandler.getScores().values().max():
		signalVisible = true
	
	if hasSignal != signalVisible:
		changeBetSignalStatus(signalVisible)
		hasSignal = signalVisible

func changeBetSignalStatus(isVisible : bool):
	$BetSignalSprite.visible = true
	
	var scaleTween = create_tween()
	scaleTween.tween_property($BetSignalSprite, "scale",\
		Vector3.ONE * (betSignalScale if isVisible else 0), .1)
	scaleTween.tween_callback(func (): $BetSignalSprite.visible = isVisible)

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
