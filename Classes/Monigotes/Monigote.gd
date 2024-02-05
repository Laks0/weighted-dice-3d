extends Pushable
class_name Monigote

signal died

@export var MAX_SPEED    : float = 7
@export var ACCELERATION : float = 20
@export var FRICTION     : float = 35
@export var GRABBING_SPEED_FACTOR : float = .05

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

var grabs : int = 0 ## Cantidad de veces que aggaró a alguien. Para MostGrabs

func _ready():
	# El id del objeto player determina la skin que usa el monigote.
	# La relación ID/Skin se determina en el diccionario exportado skins y acá.
	# Para agregar una nueva skin hace falta agregarla al enum de
	# PlayerHandler.Skins y también al diccionario de Monigote
	match player.id:
		PlayerHandler.Skins.BLUE:
			$AnimatedSprite.sprite_frames = skins.get("Blue")
		PlayerHandler.Skins.RED:
			$AnimatedSprite.sprite_frames = skins.get("Red")
		PlayerHandler.Skins.YELLOW:
			$AnimatedSprite.sprite_frames = skins.get("Yellow")
		PlayerHandler.Skins.GREEN:
			$AnimatedSprite.sprite_frames = skins.get("Green")
	
	super._ready()

func _process(_delta):
	invincible = !$HurtTime.is_stopped()
	
	if Input.is_action_just_pressed(actions.grab):
		for body in $GrabArea.get_overlapping_bodies():
			if not body is Pushable or body == self:
				continue
			
			var success : bool = startGrab(body)
			if !success:
				continue
			if body is Monigote:
				grabs += 1
			break
	
	if grabbing and Input.is_action_just_released(actions.grab):
		push()
	
	$AnimatedSprite.modulate = color
	if invincible and $HurtTime.one_shot:
		$AnimatedSprite.modulate.a = .7
	elif stunned:
		$AnimatedSprite.modulate = Color.DARK_GRAY
	else:
		$AnimatedSprite.modulate.a = 1
	
	position.y = Globals.SPRITE_HEIGHT
	
	# DEBUG
	if Input.is_action_just_pressed("die"):
		emit_signal("died")

func _physics_process(delta):
	var dir : Vector2 = Controllers.getDirection(controller)
	
	var accFactor := 1.0
	if grabbing:
		accFactor = GRABBING_SPEED_FACTOR
		onGrabbing()
	
	if stunned:
		accFactor = 0
	
	moveVelocity += ACCELERATION * dir * delta * accFactor
	moveVelocity = moveVelocity.limit_length(MAX_SPEED * (GRABBING_SPEED_FACTOR if grabbing else 1.0))
	
	unclampedVelocity = unclampedVelocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if sign(dir.x) != sign(moveVelocity.x):
		moveVelocity.x = move_toward(moveVelocity.x, 0, FRICTION * delta)
	if sign(dir.y) != sign(moveVelocity.y):
		moveVelocity.y = move_toward(moveVelocity.y, 0, FRICTION * delta)
	
	var vel2d : Vector2 = moveVelocity + unclampedVelocity
	
	velocity = Vector3(vel2d.x, velocity.y, vel2d.y)
	
	move_and_slide()
	
	# Animaciones
	match vecToDir(dir):
		Cardinal.N:
			$AnimatedSprite.play("RunningUp")
		Cardinal.E:
			$AnimatedSprite.play("RunningRight")
		Cardinal.W:
			$AnimatedSprite.play("RunningLeft")
		Cardinal.S:
			$AnimatedSprite.play("RunningDown")
	
	if dir == Vector2.ZERO:
		$AnimatedSprite.animation = "Idle"
	
	if not unclampedVelocity.is_zero_approx():
		$AnimatedSprite.play("Pushed")
		$AnimatedSprite.frame = vecToDir(unclampedVelocity)
	
	if grabbing:
		$AnimatedSprite.animation = "Grabbing"
		$AnimatedSprite.frame = vecToDir(grabDir)

func canBeGrabbed(_grabber) -> bool:
	return not invincible

func onGrabbing():
	var pointing := Controllers.getDirection(controller)
	if pointing != Vector2.ZERO:
		grabDir = pointing
	
	super.onGrabbing()

func onPushed(dir : Vector2, factor : float):
	unclampedVelocity += dir * factor * maxPushForce
	
	super.onPushed(dir, factor)

func knockback(vel : Vector2):
	unclampedVelocity += vel

func hurt():
	if invincible:
		return
	
	health -= 1
	$HurtTime.start()
	
	if health <= 0:
		die()

func die():
	emit_signal("died")
	
	$AnimatedSprite.visible = false
	$DeathParticles.emitting = true
	
	$DeathParticles.connect("finished", queue_free)

func stun():
	if !$StunCooldown.is_stopped():
		return
	
	$StunCooldown.start()
	stunned = true

func makeInvincible():
	$HurtTime.one_shot = false
	$HurtTime.start()

enum Cardinal {E, NE, N, NW, W, SW, S, SE}

func vecToDir(vector : Vector2) -> Cardinal:
	var angle = -vector.angle()
	if angle < 0:
		angle += 2*PI
	
	angle += PI/8
	return floor( angle / (PI/4) )

func _on_stun_cooldown_timeout():
	stunned = false
