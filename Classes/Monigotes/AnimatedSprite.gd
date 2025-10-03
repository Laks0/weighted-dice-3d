extends AnimatedSprite3D
class_name MonigoteSprite

signal betSignalStatusChanged(isVisible : bool)

var onArena := false

@export var mon : Monigote

@export var crownTexture : Texture
@export var jokerHatTexture : Texture

@export var betSignalScale : int = 4

@export var shakeMagnitude := .4
@export var shakeTime := .1

@export var drunkColor : Color = Color.DARK_MAGENTA

var hurtSkin : SpriteFrames

@export var skins : Dictionary

@onready var animationHandler : MonigoteAnimation3DHandler = $Animations3D

var _animationStopped := false

func _ready():
	# El id del objeto player determina la skin que usa el monigote.
	# La relación ID/Skin se determina en el diccionario exportado skins y acá.
	# Para agregar una nueva skin hace falta agregarla al enum de
	# PlayerHandler.Skins y también al diccionario de Monigote
	match mon.player.id:
		PlayerHandler.Skins.BLUE: #FRAN
			sprite_frames = skins.get("Blue")
			hurtSkin = skins.get("BlueBloody")
		PlayerHandler.Skins.RED: #TOMI
			sprite_frames = skins.get("Red")
			hurtSkin = skins.get("RedBloody")
		PlayerHandler.Skins.YELLOW: #PEDRO
			sprite_frames = skins.get("Yellow")
			hurtSkin = skins.get("YellowBloody")
		PlayerHandler.Skins.GREEN: #JUAN
			sprite_frames = skins.get("Green")
			hurtSkin = skins.get("GreenBloody")
		PlayerHandler.Skins.ORANGE: #MALE
			sprite_frames = skins.get("Orange")
			hurtSkin = skins.get("OrangeBloody")
		PlayerHandler.Skins.PURPLE: #MARTA
			sprite_frames = skins.get("Purple")
			hurtSkin = skins.get("PurpleBloody")
	
	material_override.set_shader_parameter("outline_color", mon.player.color)

func arenaReady():
	onArena = true
	var currentBet : Bet = BetHandler.currentBet
	$PlayerName.visible = true
	$PlayerName.text = mon.player.name
	$PlayerName.modulate = mon.player.color
	
	if currentBet == null:
		return
	
	########################
	# Señalizador de apuesta
	########################
	match currentBet.monigoteSignal:
		Bet.MonigoteSignal.CROWN: $BetSignalSprite.texture = crownTexture
		Bet.MonigoteSignal.JOKER_HAT: $BetSignalSprite.texture = jokerHatTexture

## Si se muestra un señalizador de apuesta
var hasSignal := false


@onready var _localLabelPosition = $PlayerName.position
var _nameInLocalSpace := true

func _process(delta):
	material_override.set_shader_parameter("spriteTexture", sprite_frames.get_frame_texture(animation, frame))
	material_override.set_shader_parameter("modulate", modulate)
	
	modulate = mon.color
	if mon.invincible and not mon.grabbed:
		modulate.a = .7
	elif mon.movement.stunned:
		modulate = Color.GRAY
	else:
		modulate.a = .95
	
	if mon.drunk:
		modulate *= drunkColor
	
	if _nameInLocalSpace:
		$PlayerName.position = lerp($PlayerName.position, _localLabelPosition, 20*delta)
	else:
		$PlayerName.global_position = lerp($PlayerName.global_position, global_position+Vector3.UP*.3, 20*delta)
	
	#############
	# Animaciones
	#############
	
	if _animationStopped:
		return
	
	# Si el monigote está pausado no hay animaciones
	if not mon.is_processing():
		modulate = Color.WHITE
		play("Idle")
		return

	if not mon.movement.getMovementDir().is_zero_approx():
		match vecTo4Dir(mon.movement.getMovementDir()):
			Cardinal.E: play("RunningRight")
			Cardinal.W: play("RunningLeft")
			Cardinal.S: play("RunningDown")
			Cardinal.N: play("RunningUp")
	else:
		play("Idle")
	
	if not mon.movement.getUnclampedVelocity().is_zero_approx():
		play("Pushed")
		frame = vecTo8Dir(mon.movement.getUnclampedVelocity())
	
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
	if BetHandler.getCandidateScore(mon.player.id) == \
			BetHandler.getScores()[BetHandler.getCandidatesInOrder()[0]]:
		signalVisible = true
	
	if hasSignal != signalVisible:
		changeBetSignalStatus(signalVisible)
		hasSignal = signalVisible

func dance():
	stopAnimations()
	speed_scale = 1
	play("Dancing")

func changeBetSignalStatus(isVisible : bool):
	$BetSignalSprite.visible = true
	
	var scaleTween = create_tween()
	scaleTween.tween_property($BetSignalSprite, "scale",\
		Vector3.ONE * (betSignalScale if isVisible else 0), .1)
	scaleTween.tween_callback(func (): $BetSignalSprite.visible = isVisible)
	
	betSignalStatusChanged.emit(isVisible)

func onMonigoteHurt():
	sprite_frames = hurtSkin
	var labelTween = create_tween().set_loops()
	labelTween.tween_property($PlayerName, "modulate:a", .4, .2)
	labelTween.tween_property($PlayerName, "modulate:a", 1, .2)
	startNameShake()

## Empieza el temblor de la nametag, una vez que se llama no se detiene
func startNameShake():
	while true:
		$PlayerName.rotation.z = randf() * (PI/10) - PI/20
		await get_tree().create_timer(.05).timeout

## Un temblor corto planar al sprite
func planarShake() -> void:
	var elapsedTime := .0
	while elapsedTime < shakeTime:
		position = Vector3.RIGHT * randf_range(-shakeMagnitude, shakeMagnitude)\
			* (shakeTime - elapsedTime) / shakeTime
		elapsedTime += get_process_delta_time()
		await get_tree().process_frame
	
	position = Vector3.ZERO

func stopAnimations() -> void:
	_animationStopped = true
	speed_scale = 0

func resumeAnimations() -> void:
	_animationStopped = false
	speed_scale = 1

func setNameToGlobalSpace() -> void:
	$PlayerName.billboard = BaseMaterial3D.BillboardMode.BILLBOARD_ENABLED
	_nameInLocalSpace = false

func setNameToLocalSpace() -> void:
	$PlayerName.billboard = BaseMaterial3D.BillboardMode.BILLBOARD_DISABLED
	_nameInLocalSpace = true

var _manualAnimationLock : int = 0

func startManualAnimation() -> void:
	_manualAnimationLock += 1
	if _manualAnimationLock <= 1:
		$Animations3D.startManualAnimation()
		stopAnimations()

func endManualAnimation() -> void:
	_manualAnimationLock -= 1
	_manualAnimationLock = max(_manualAnimationLock, 0)
	if _manualAnimationLock <= 0:
		$Animations3D.endManualAnimation()
		resumeAnimations()

## Solo tiene efecto cuando están activadas las animaciones manuales
func setFeetLookingAt(dir2dToLookAt : Vector2, rotationPercentage : float, faceDown := false) -> void:
	$Animations3D.setFeetLookingAt(dir2dToLookAt, rotationPercentage)
	
	play("Pushed")
	frame = 2 if faceDown else 6

enum Cardinal {E, NE, N, NW, W, SW, S, SE}

## Saca ángulos de la forma normal (desde 0 hasta 2PI), Godot lo hace de una manera rara
func _regularAngle(vector : Vector2) -> float:
	var angle = -vector.angle()
	if angle < 0:
		angle += 2*PI
	return angle

func vecTo8Dir(vector : Vector2) -> Cardinal:
	var angle = _regularAngle(vector)
	angle += PI/8
	return floor( angle / (PI/4) )

func vecTo4Dir(vector : Vector2) -> Cardinal:
	var angle = _regularAngle(vector)
	if angle > 7*PI/4 or angle < PI/4:
		return Cardinal.E
	elif angle > PI/4 and angle < 3*PI/4:
		return Cardinal.N
	elif angle > 3*PI/4 and angle < 5*PI/4:
		return Cardinal.W
	return Cardinal.S
