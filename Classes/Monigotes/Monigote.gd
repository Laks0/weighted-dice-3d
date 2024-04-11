extends Pushable
class_name Monigote

signal died
## Se emite cuando el monigote agarra cualquier pushable
signal grab(body)

@export var scoreParticle : PackedScene

@export var MAX_SPEED    : float = 7
@export var ACCELERATION : float = 20
@export var GRABBING_SPEED_FACTOR : float = .05
@export var MOVEMENTS_TO_ESCAPE_GRAB : int = 20
var escapeMovements : int = 0

var _movementDir : Vector2

@export var aiControllerScript : Script

var player : PlayerHandler.Player = PlayerHandler.Player.new("Juan")
@onready var controller : int = player.inputController
@onready var actions    : Dictionary = Controllers.getActions(controller)

var moveVelocity      := Vector2.ZERO
var unclampedVelocity := Vector2.ZERO

var stunned := false
var health : int = 2

var invincible  := false

@export var invincibleAfterHurtTime: float = 3.0
@export var invincibleAfterPushTime: float = 0.2

@export var skins : Dictionary

var stageHandler : StageHandler

var drunk := false

func _ready():
	# El id del objeto player determina la skin que usa el monigote.
	# La relación ID/Skin se determina en el diccionario exportado skins y acá.
	# Para agregar una nueva skin hace falta agregarla al enum de
	# PlayerHandler.Skins y también al diccionario de Monigote
	match player.id:
		PlayerHandler.Skins.BLUE:
			%AnimatedSprite.sprite_frames = skins.get("Blue")
		PlayerHandler.Skins.RED:
			%AnimatedSprite.sprite_frames = skins.get("Red")
		PlayerHandler.Skins.YELLOW:
			%AnimatedSprite.sprite_frames = skins.get("Yellow")
		PlayerHandler.Skins.GREEN:
			%AnimatedSprite.sprite_frames = skins.get("Green")
		PlayerHandler.Skins.ORANGE:
			%AnimatedSprite.sprite_frames = skins.get("Orange")
		PlayerHandler.Skins.PURPLE:
			%AnimatedSprite.sprite_frames = skins.get("Purple")
	
	$HurtTime.timeout.connect(func(): invincible = false)
	
	stageHandler = get_parent().get_node("StageHandler")
	
	super._ready()

	if player.inputController == Controllers.AI:
		var controllerNode := Node.new()
		controllerNode.set_script(aiControllerScript)
		add_child(controllerNode)

## Se llama desde la arena cuando el monigote es reparentado
func arenaReady():
	$AnimatedSprite.arenaReady()

## El último score de la apuesta, solo se usa si se apuesta sobre jugadores
var _lastScore: float = 0

func _process(_delta):
	if Input.is_action_just_pressed(actions.grab):
		if grabbed:
			attemptEscape()
		for body in $GrabArea.get_overlapping_bodies():
			if not body is Pushable or body == self:
				continue
			
			var success : bool = startGrab(body)
			if !success:
				continue
			
			$GrabCooldown.start()
			emit_signal("grab", body)
			break
	
	if grabbing and Input.is_action_just_released(actions.grab):
		push()
	
	# DEBUG
	if Input.is_action_just_pressed("die") and player.id == 0:
		die()
	
	if stageHandler.currentStage != StageHandler.Stages.ARENA:
		return
		
	position.y = Globals.SPRITE_HEIGHT
	
	if not BetHandler.currentBet.betType in [Bet.BetType.EXCLUDE_SELF, Bet.BetType.ALL_PLAYERS]:
		return
	
	var newScore = BetHandler.getCandidateScore(player.id)
	if floori(newScore) != floori(_lastScore):
		emitScore(floori(newScore))
	_lastScore = newScore

func _physics_process(delta):
	if player.inputController != Controllers.AI:
		_movementDir = Controllers.getDirection(controller)
	
	if drunk:
		_movementDir = _movementDir.rotated(PI)
	
	var accFactor := 1.0
	if grabbing:
		accFactor = GRABBING_SPEED_FACTOR
		onGrabbing()
	
	if stunned:
		accFactor = 0
	
	moveVelocity += ACCELERATION * _movementDir * delta * accFactor
	moveVelocity = moveVelocity.limit_length(MAX_SPEED * (GRABBING_SPEED_FACTOR if grabbing else 1.0))
	
	unclampedVelocity = unclampedVelocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if sign(_movementDir.x) != sign(moveVelocity.x):
		moveVelocity.x = move_toward(moveVelocity.x, 0, FRICTION * delta)
	if sign(_movementDir.y) != sign(moveVelocity.y):
		moveVelocity.y = move_toward(moveVelocity.y, 0, FRICTION * delta)
	
	var vel2d : Vector2 = moveVelocity + unclampedVelocity
	
	velocity = Vector3(vel2d.x, velocity.y, vel2d.y)
	
	move_and_slide()
	
	# Detiene las partículas si se interrumpió el movimiento
	if velocity.is_zero_approx():
		$PushedParticles.emitting = false

func resetMovement() -> void:
	moveVelocity = Vector2.ZERO
	unclampedVelocity = Vector2.ZERO
	velocity = Vector3.ZERO

func canBeGrabbed(grabber) -> bool:
	return (self != grabber) and (not invincible) and (not grabbed)

func canGrab() -> bool:
	return $GrabCooldown.is_stopped() and (not grabbed) and (not grabbing)

func startGrab(body : Pushable) -> bool:
	if not super(body):
		return false
	
	return true

func attemptEscape():
	$AnimatedSprite.shake()
	escapeMovements += 1
	if escapeMovements >= MOVEMENTS_TO_ESCAPE_GRAB:
		$GrabCooldown.start()
		escaped.emit()

func onGrabbingEscaped(body : Pushable):
	var bodyPos2d = Vector2(body.position.x, body.position.z)
	var pos2d = Vector2(position.x, position.z)
	knockback(bodyPos2d.direction_to(pos2d) * 14)

func onGrabbed():
	escapeMovements = 0
	invincible = true
	super()

func onGrabbing():
	var pointing := Controllers.getDirection(controller)
	if pointing != Vector2.ZERO:
		grabDir = pointing
	
	super.onGrabbing()

func onPushed(dir : Vector2, factor : float, _pusher : Pushable):
	unclampedVelocity += dir * factor * maxPushForce
	
	if factor == 1:
		$Audio/YellSuperpush.play()
	else:
		$Audio/YellPush.play()
	
	invincible = false
	
	super(dir, factor, _pusher)
	
	##############
	# Partículas #
	##############
	# Solo las genera a partir de factor .5
	if factor < .5:
		return
	
	# Se espera un poco antes de crear las partículas
	await get_tree().create_timer(.1).timeout
	
	$PushedParticles.amount = floor(factor * 3)
	$PushedParticles.emitting = true

func push():
	moveVelocity = Vector2.ZERO
	knockback(-grabDir * 5)
	super()

func knockback(vel : Vector2):
	unclampedVelocity += vel

func hurt() -> bool:
	if invincible:
		return false
	
	health -= 1
	
	$Audio/YellStomp.play()
	
	if health <= 0:
		die()
	
	makeInvincible()
	
	return true

func die():
	if invincible:
		return
	
	if grabbing:
		push()
	
	emit_signal("died")
	
	frameFeeze(.005, .4)
	
	$Audio/YellStomp.play()
	
	%AnimatedSprite.visible = false
	$DeathParticles.emitting = true
	
	$DeathParticles.connect("finished", queue_free)

func stun():
	if !$StunCooldown.is_stopped():
		return
	
	$Audio/YellSpike.play()
	
	$StunCooldown.start()
	stunned = true

func makeInvincible():
	invincible = true
	$HurtTime.start()

func _on_stun_cooldown_timeout():
	stunned = false

func emitScore(n : int):
	var particle = scoreParticle.instantiate()
	add_child(particle)
	
	particle.draw_pass_1.material.albedo_color = player.color
	particle.draw_pass_1.text = str(n)
	
	particle.emitting = true
	
	particle.connect("finished", particle.queue_free)

func frameFeeze(timeScale : float, duration : float):
	$DeathLight.visible = true
	Engine.set_time_scale(timeScale)
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.set_time_scale(1)
	$DeathLight.visible = false
