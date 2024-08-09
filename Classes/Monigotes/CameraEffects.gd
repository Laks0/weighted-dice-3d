extends Node3D

@onready var mon := get_parent() as Monigote

@export var hurtShakeMagnitude := .03
@export var hurtShakeTime := .1

@export var deathShakeMagnitude := .2
@export var deathShakeTime := .4

func _ready():
	mon.wasHurt.connect(onHurt)
	mon.died.connect(onDeath)

func onHurt():
	if mon.health == 0:
		return
	
	frameFeeze(.005, hurtShakeTime)
	
	var camera = get_viewport().get_camera_3d()
	if camera is MultipleResCamera:
		camera.startShake(hurtShakeMagnitude, hurtShakeTime)

func onDeath():
	$DeathLight.visible = true
	
	var camera = get_viewport().get_camera_3d()
	if camera is MultipleResCamera:
		camera.startShake(deathShakeMagnitude, deathShakeTime)
	
	await frameFeeze(.005, deathShakeTime).timeout
	$DeathLight.visible = false

func frameFeeze(timeScale : float, duration : float) -> SceneTreeTimer:
	Engine.set_time_scale(timeScale)
	var freezeTimer := get_tree().create_timer(duration, true, false, true)
	freezeTimer.timeout.connect(Engine.set_time_scale.bind(1))
	return freezeTimer
