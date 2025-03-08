extends AnimatedSprite3D

var onArena := false

@export var mon : Monigote

@export var crownTexture : Texture
@export var jokerHatTexture : Texture

@export var betSignalScale : int = 4

@export var shakeMagnitude := .4
@export var shakeTime := .1

@onready var currentRotationRaycast := $RotationRaycastNoSignal

@export var drunkColor : Color = Color.DARK_MAGENTA

var hurtSkin : SpriteFrames

@export var skins : Dictionary

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
	
	# Para la función de rotación
	$RotationRaycastNoSignal.add_exception(get_parent())

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

var dancing = false

func _process(_delta):
	material_override.set_shader_parameter("spriteTexture", sprite_frames.get_frame_texture(animation, frame))
	material_override.set_shader_parameter("modulate", modulate)
	
	modulate = mon.color
	if mon.invincible and not mon.grabbed:
		modulate.a = .7
	elif mon.stunned:
		modulate = Color.GRAY
	else:
		modulate.a = 1
	
	if mon.drunk:
		modulate *= drunkColor
	
	if mon.grabbed:
		rotation.x = min(-PI/2 * mon.forceBeingGrabbed, getNewRotation())
		rotation.y = PI/2-mon.dirBeingGrabbed.angle()
		modulate.a = .7
	else:
		billboardUpdate()
	
	#############
	# Animaciones
	#############
	
	if dancing:
		return
	
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
	if BetHandler.getCandidateScore(mon.player.id) == \
			BetHandler.getScores()[BetHandler.getCandidatesInOrder()[0]]:
		signalVisible = true
	
	if hasSignal != signalVisible:
		changeBetSignalStatus(signalVisible)
		hasSignal = signalVisible

func dance():
	dancing = true
	play("Dancing")

############
# Rotación
############

## Retorna cuál debería ser la rotación en el eje x del sprite en su posición, con el efecto
## secundario de rotar el raycast lo que sea necesario
func getNewRotation() -> float:
	# Billboard normal
	var billboardRotation := get_viewport().get_camera_3d().rotation.x + PI/8
	
	if not currentRotationRaycast.is_colliding():
		currentRotationRaycast.rotation.x = 0
		return billboardRotation
	
	var collisionPoint : Vector3 = currentRotationRaycast.get_collision_point()
	# angulo = arcos(A/H)
	var rayLength : float = currentRotationRaycast.target_position.y
	var newRotation := acos(abs(collisionPoint.z - global_position.z) / rayLength) - PI/2
	currentRotationRaycast.rotation.x = billboardRotation - newRotation
	return newRotation

var transitioningRotation := false
var rotationAnimationTreshold := PI/8 # La máxima cantidad que se puede rotar en un frame sin tween
## Rota el sprite como billboard a menos que se choque contra un cuerpo
func billboardUpdate():
	if transitioningRotation:
		return
	
	var newRotation = getNewRotation()
	
	# Reajuste de altura
	var spriteHalfHeight := .05
	var feetHeight := cos(newRotation) * spriteHalfHeight
	
	# Si la rotación nueva es lo suficientemente parecida se puede pasar en un solo frame
	if abs(newRotation - rotation.x) < rotationAnimationTreshold:
		position.y = feetHeight
		rotation.x = newRotation
		return
	
	# Si no, se anima la rotación
	transitioningRotation = true
	var tween = create_tween().set_parallel(true)
	var time := .08
	tween.tween_property(self, "rotation:x", newRotation, time)
	tween.tween_property(self, "position:y", feetHeight, time)
	
	await tween.finished
	
	transitioningRotation = false

func changeBetSignalStatus(isVisible : bool):
	$BetSignalSprite.visible = true
	
	var scaleTween = create_tween()
	scaleTween.tween_property($BetSignalSprite, "scale",\
		Vector3.ONE * (betSignalScale if isVisible else 0), .1)
	scaleTween.tween_callback(func (): $BetSignalSprite.visible = isVisible)
	
	# Para la función de rotación
	$RotationRaycastNoSignal.enabled = !isVisible
	$RotationRaycastSignal.enabled = isVisible
	currentRotationRaycast = $RotationRaycastSignal if isVisible else $RotationRaycastNoSignal

func onMonigoteHurt():
	sprite_frames = hurtSkin
	var labelTween = create_tween().set_loops()
	labelTween.tween_property($PlayerName, "modulate:a", .4, .2)
	labelTween.tween_property($PlayerName, "modulate:a", 1, .2)
	startNameShake()

func onMonigoteGrab(body : Pushable):
	$RotationRaycastNoSignal.add_exception(body)
	$RotationRaycastSignal.add_exception(body)

func onMonigotePushed():
	$RotationRaycastNoSignal.clear_exceptions()
	$RotationRaycastSignal.clear_exceptions()

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

## Un temblor corto en el eje y
func axisShake(maxAngle : float = PI/10, totalRotations : int = 4, time : float = 1):
	var localYAxis := basis.y.normalized()
	rotate(localYAxis, PI/2)

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
