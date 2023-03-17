extends Pushable
class_name Monigote

@export var MAX_SPEED    : float = 7
@export var ACCELERATION : float = 20
@export var FRICTION     : float = 35

var player : PlayerHandler.Player = PlayerHandler.Player.new("Juan")
@onready var controller : int = player.inputController
@onready var actions    : Dictionary = Controllers.getActions(controller)

var moveVelocity      := Vector2.ZERO
var unclampedVelocity := Vector2.ZERO

var stunned := false
var health : int = 2

var invincible  := false
var ungrabbable := false

@export var invincibleAfterHurtTime: float = 3.0
@export var invincibleAfterPushTime: float = 0.2

var sprite : AnimatedSprite3D

func _ready():
	match player.id:
		PlayerHandler.Skins.BLUE:
			sprite = $FranciscoSprite
		PlayerHandler.Skins.RED:
			sprite = $TomiSprite
		PlayerHandler.Skins.YELLOW:
			sprite = $PedroSprite
		PlayerHandler.Skins.GREEN:
			sprite = $JaviSprite
	
	sprite.visible = true
	
	super._ready()

func _process(_delta):
	invincible = !$HurtTime.is_stopped()
	
	if Input.is_action_just_pressed(actions.grab):
		for body in $GrabArea.get_overlapping_bodies():
			if not body is Pushable or body == self:
				continue
			
			startGrab(body)
			break
	
	if grabbing and Input.is_action_just_released(actions.grab):
		push()
	
	sprite.modulate = color

func _physics_process(delta):
	var dir : Vector2 = Controllers.getDirection(controller)

	if grabbing:
		dir = Vector2.ZERO
		onGrabbing()
	
	moveVelocity += ACCELERATION * dir * delta
	moveVelocity = moveVelocity.limit_length(MAX_SPEED)
	
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
			sprite.animation = "RunningUp"
		Cardinal.E:
			sprite.animation = "RunningRight"
		Cardinal.W:
			sprite.animation = "RunningLeft"
		Cardinal.S:
			sprite.animation = "RunningDown"
	
	if dir == Vector2.ZERO:
		sprite.animation = "Idle"
	
	if not unclampedVelocity.is_zero_approx():
		sprite.animation = "Pushed"
		sprite.frame = vecToDir(unclampedVelocity)
	
	if grabbing:
		sprite.animation = "Grabbing"
		sprite.frame = vecToDir(grabDir)

func canBeGrabbed() -> bool:
	return not invincible

func onGrabbing():
	var pointing := Controllers.getDirection(controller)
	if pointing != Vector2.ZERO:
		grabDir = pointing
	
	super.onGrabbing()

func onPushed(dir : Vector2, factor : float):
	unclampedVelocity += dir * factor * maxPushForce
	
	super.onPushed(dir, factor)

func stun():
	if !$StunCooldown.is_stopped():
		return
	
	$StunCooldown.start()
	stunned = true

enum Cardinal {E, NE, N, NW, W, SW, S, SE}

func vecToDir(vector : Vector2) -> Cardinal:
	var angle = -vector.angle()
	if angle < 0:
		angle += 2*PI
	
	angle += PI/8
	return floor( angle / (PI/4) )

func _on_stun_cooldown_timeout():
	stunned = false
