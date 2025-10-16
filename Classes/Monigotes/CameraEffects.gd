extends Node3D

@onready var mon := get_parent() as Monigote

@export var hurtShakeMagnitude := .03
@export var hurtShakeTime := .1

@export var deathShakeMagnitude := .2
@export var deathShakeTime := .4

@export var amountOfHurtRaysOnHit : int = 5
@export var amountOfHurtRaysOnDeath : int = 15

@export var hurtParticlesArray : Array[GPUParticles3D]

@export var headLifetime : float = 1

func _ready():
	mon.wasHurt.connect(onHurt)
	mon.died.connect(onDeath)
	
	for p in hurtParticlesArray:
		p.draw_pass_1.material.albedo_color = mon.player.color

var _freezeTimeScale :float= .2

func _startHurtEffect(freezeTime : float, shakeMagnitude : float):
	$BloodSplat.speed_scale = 1/_freezeTimeScale
	$BloodSplat.restart()
	
	var camera = get_viewport().get_camera_3d()
	if camera is MultipleResCamera:
		camera.startShake(shakeMagnitude, freezeTime)
	
	for p in hurtParticlesArray:
		p.speed_scale = 1/_freezeTimeScale
		p.restart()
	
	frameFeeze(_freezeTimeScale, freezeTime)
	
	$HurtTrails.speed_scale = 1.5
	$HurtTrails2.speed_scale = 1.5
	$BloodSplat.speed_scale = 1.5

func onHurt():
	if mon.health == 0:
		return
	
	Input.start_joy_vibration(mon.controller, .4, .4, .2)
	
	$BloodTrail.emitting = true
	
	for p in hurtParticlesArray:
		p.lifetime = hurtShakeTime + .3
		p.amount = amountOfHurtRaysOnHit
	
	_startHurtEffect(hurtShakeTime, hurtShakeMagnitude)
	mon.startAfterHurtInvincibleTime()

func onDeath():
	if not $BloodTrail.emitting:
		$BloodTrail.restart()
	
	$DeathLight.visible = true
	Input.start_joy_vibration(mon.controller, 1, 1, .4)
	
	for p in hurtParticlesArray:
		p.lifetime = deathShakeTime + .3
		p.amount = amountOfHurtRaysOnDeath
	
	%AnimatedSprite.visible = false
	$DeathParticles.restart()
	
	$Head.visible = true
	$Head.texture = %AnimatedSprite.getHeadTexture()
	
	await _startHurtEffect(deathShakeTime, deathShakeMagnitude)
	
	$DeathLight.visible = false
	
	var tween := create_tween()
	tween.tween_interval(2*headLifetime/3)
	tween.tween_property($Head, "modulate:a", 0, headLifetime/3)
	tween.tween_callback(mon.queue_free)

# Ser agarrado puede resetear esto así que hay que hacerlo todos los frames
func _process(_delta: float) -> void:
	if mon.health == 0:
		mon.stopMovement()
		mon.stopGrabbing()
		$Head.basis = %AnimatedSprite.basis

func frameFeeze(timeScale : float, duration : float) -> SceneTreeTimer:
	Engine.set_time_scale(timeScale)
	var freezeTimer := get_tree().create_timer(duration, true, false, true)
	freezeTimer.timeout.connect(Engine.set_time_scale.bind(1))
	return freezeTimer
