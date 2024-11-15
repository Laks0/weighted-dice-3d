extends Pushable
class_name Monigote

signal wasHurt
@warning_ignore("unused_signal")
signal died
## Se emite cuando el monigote agarra cualquier pushable
@warning_ignore("unused_signal")
signal grab(body)
@warning_ignore("unused_signal")
signal hasWon

@export var scoreParticle : PackedScene

@export var MAX_SPEED    : float = 7
@export var ACCELERATION : float = 20
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

# Se activa en jump(), se desactiva en onFloorColision()
var jumping := false
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
		PlayerHandler.Skins.BLUE: #FRAN
			%AnimatedSprite.sprite_frames = skins.get("Blue")
			%AnimatedSprite.hurtSkin = skins.get("BlueBloody")
		PlayerHandler.Skins.RED: #TOMI
			%AnimatedSprite.sprite_frames = skins.get("Red")
			%AnimatedSprite.hurtSkin = skins.get("RedBloody")
		PlayerHandler.Skins.YELLOW: #PEDRO
			%AnimatedSprite.sprite_frames = skins.get("Yellow")
			%AnimatedSprite.hurtSkin = skins.get("YellowBloody")
		PlayerHandler.Skins.GREEN: #JUAN
			%AnimatedSprite.sprite_frames = skins.get("Green")
			%AnimatedSprite.hurtSkin = skins.get("GreenBloody")
		PlayerHandler.Skins.ORANGE: #MALE
			%AnimatedSprite.sprite_frames = skins.get("Orange")
			%AnimatedSprite.hurtSkin = skins.get("OrangeBloody")
		PlayerHandler.Skins.PURPLE: #MARTA
			%AnimatedSprite.sprite_frames = skins.get("Purple")
			%AnimatedSprite.hurtSkin = skins.get("PurpleBloody")
	
	$HurtTime.timeout.connect(func(): invincible = false)
	
	stageHandler = get_parent().get_node_or_null("StageHandler")
	
	if player.inputController == Controllers.AI:
		var controllerNode := Node.new()
		controllerNode.set_script(aiControllerScript)
		add_child(controllerNode)
	
	super._ready()

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
	if Input.is_action_just_pressed("die"):
		die()
	
	if stageHandler.currentStage != StageHandler.Stages.ARENA:
		return
	
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
	if grabbing and is_instance_valid(grabBody):
		accFactor = grabBody.grabSpeedFactor
		onGrabbing()
	
	if stunned:
		accFactor = 0
	
	moveVelocity += ACCELERATION * _movementDir * delta * accFactor
	moveVelocity = moveVelocity.limit_length(MAX_SPEED * accFactor)
	
	unclampedVelocity = unclampedVelocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if sign(_movementDir.x) != sign(moveVelocity.x):
		moveVelocity.x = move_toward(moveVelocity.x, 0, FRICTION * delta)
	if sign(_movementDir.y) != sign(moveVelocity.y):
		moveVelocity.y = move_toward(moveVelocity.y, 0, FRICTION * delta)
	
	var vel2d : Vector2 = moveVelocity + unclampedVelocity
	
	velocity.y -= 50*delta
	velocity = Vector3(vel2d.x, velocity.y, vel2d.y)
	
	if Input.is_action_just_pressed(actions.jump):
		jump()
	
	move_and_slide()

func resetMovement() -> void:
	moveVelocity = Vector2.ZERO
	unclampedVelocity = Vector2.ZERO
	velocity = Vector3.ZERO

func canBeGrabbed(grabber) -> bool:
	return (self != grabber) and (not invincible) and (not grabbed) and (not jumping)

func canGrab() -> bool:
	return $GrabCooldown.is_stopped() and (not grabbed) and (not grabbing) and (not jumping)

func startGrab(body : Pushable) -> bool:
	if not super(body):
		return false
	
	return true

func attemptEscape():
	$AnimatedSprite.shake()
	escapeMovements += 1
	Input.start_joy_vibration(controller, .3, 0, .2)
	
	if escapeMovements >= MOVEMENTS_TO_ESCAPE_GRAB:
		$GrabCooldown.start()
		escaped.emit()
		Input.start_joy_vibration(controller, 1, 0, .1)

func onGrabbingEscaped(body : Pushable):
	var bodyPos2d = Vector2(body.position.x, body.position.z)
	var pos2d = Vector2(position.x, position.z)
	knockback(bodyPos2d.direction_to(pos2d) * 14)
	Input.start_joy_vibration(controller, 1, 0, .25)

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
	
	$GrabCooldown.start()
	
	invincible = false
	
	super(dir, factor, _pusher)

func push():
	moveVelocity = Vector2.ZERO
	knockback(-grabDir * pow(pushFactor, 2) * 11)
	Input.start_joy_vibration(controller, pushFactor, 0, .1)
	super()

func jump():
	if jumping or not $JumpCooldown.is_stopped():
		return
	velocity.y = 10
	jumping = true

func onFloorColision(body):
	if jumping and body is StaticBody3D:
		jumping = false
		$JumpCooldown.start()

func bounce(normal : Vector3):
	var normal2 := Vector2(normal.x, normal.z)
	unclampedVelocity = unclampedVelocity.bounce(normal2)
	moveVelocity = moveVelocity.bounce(normal2)
	velocity = velocity.bounce(normal)

func knockback(vel : Vector2):
	unclampedVelocity = vel

func knockbackFrom(pos : Vector3, force : float):
	var pos2d = Vector2(pos.x, pos.z)
	var selfPos2d = Vector2(position.x, position.z)
	
	knockback(pos2d.direction_to(selfPos2d) * force)

func hurt() -> bool:
	if invincible or DebugVars.inmortalMonigotes:
		return false
	
	health -= 1
	
	if health <= 0:
		die()
	else:
		wasHurt.emit()
		Input.start_joy_vibration(controller, .4, .4, .2)
	
	makeInvincible()
	
	return true

func die():
	if invincible:
		return
	
	if grabbing:
		push()
	
	emit_signal("died")
	
	%AnimatedSprite.visible = false
	$DeathParticles.emitting = true
	
	Input.start_joy_vibration(controller, 1, 1, .4)
	
	$DeathParticles.connect("finished", queue_free)

func stun():
	if !$StunCooldown.is_stopped():
		return
	
	$StunCooldown.start()
	stunned = true

func makeInvincible():
	invincible = true
	$HurtTime.start()

## Detiene todo movimiento e interrumpe los controles, se usa en las transiciones de estado
func freeze():
	set_process(false)
	set_physics_process(false)
	moveVelocity = Vector2.ZERO
	unclampedVelocity = Vector2.ZERO
	
	push()
	if grabbed:
		escaped.emit()

func unfreeze():
	set_process(true)
	set_physics_process(true)

func _on_stun_cooldown_timeout():
	stunned = false

func emitScore(n : int):
	var particle = scoreParticle.instantiate()
	add_child(particle)
	
	particle.draw_pass_1.material.albedo_color = player.color
	particle.draw_pass_1.text = str(n)
	
	particle.emitting = true
	
	particle.connect("finished", particle.queue_free)

func dance():
	$AnimatedSprite.dance()
