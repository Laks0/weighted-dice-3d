## El script interactua con la API de Pushable del monigote, sus funciones se siguen teniendo que
## llamar desde Monigote
extends Node3D
class_name MonigoteGrabbingHandler

@export var animatedSprite : AnimatedSprite3D

@onready var mon : Monigote = get_parent()
@export var hands : Node3D

@export_category("Push charge curves")
@export var firstChargeCurve : Curve
@export var oscillationChargeCurve : Curve
@onready var _currentChargeCurve : Curve = firstChargeCurve
var _curveSampleTime : float

var forcePercentage : float = 0

func _physics_process(delta):
	var pointing := Controllers.getDirection(mon.controller)
	if pointing != Vector2.ZERO:
		mon.grabDir = pointing
		$GrabArea.rotation.y = -pointing.angle()
	
	if mon.grabbing:
		onGrabbing(delta)

func attemptGrab():
	if not $GrabCooldown.is_stopped():
		return
	
	hands.attack($GrabReadyTime.wait_time)
	$GrabReadyTime.start()
	await $GrabReadyTime.timeout
	if not Input.is_action_pressed(mon.actions["grab"]):
		onPushed()
		return
	
	forcePercentage = 0
	_currentChargeCurve = firstChargeCurve
	_curveSampleTime = 0
	
	var couldGrab := false
	for body in $GrabArea.get_overlapping_bodies():
		if not body is Pushable or body == self:
			continue
		
		var success : bool = mon.startGrab(body)
		if !success:
			continue
		
		couldGrab = true
		mon.emit_signal("grab", body)
		break
	
	if not couldGrab:
		$GrabGraceTime.start()

func onPushed():
	$GrabCooldown.start()
	if mon.grabbing:
		hands.onPush($GrabCooldown.wait_time)
	else:
		hands.goToRest($GrabCooldown.wait_time)

var _elevationPercentage : float
func getCurrentElevationPercentage() -> float:
	return _elevationPercentage

func onGrabbing(delta : float):
	if not is_instance_valid(mon.grabBody):
		return
	
	if Input.is_action_just_released(mon.actions.grab):
		pushAnimation()
		return
	
	mon.grabBody.onBeingGrabbed.emit(mon.grabDir, forcePercentage, mon)
	
	if not Input.is_action_pressed(mon.actions.grab):
		return
	
	# Determina la fuerza dependiendo del tiempo
	_curveSampleTime += delta
	forcePercentage = _currentChargeCurve.sample_baked(_curveSampleTime)
	
	if _curveSampleTime >= _currentChargeCurve.max_domain:
		if _currentChargeCurve == firstChargeCurve:
			_currentChargeCurve = oscillationChargeCurve
		_curveSampleTime = 0
	
	mon.pushFactor = forcePercentage
	
	# Prohibe al cuerpo colisionar con el que lo agarra
	mon.grabBody.add_collision_exception_with(mon)
	
	_elevationPercentage = forcePercentage
	if _currentChargeCurve == oscillationChargeCurve:
		_elevationPercentage = 1
	_elevationPercentage = clamp(_elevationPercentage, 0, mon.grabBody.maxElevation)
	
	var dir3d := Vector3(mon.grabDir.x, 0, mon.grabDir.y)
	if dir3d == Vector3.ZERO:
		dir3d = Vector3.RIGHT
	var target := Vector3.UP.rotated(Vector3(1,0,0), animatedSprite.rotation.x) * 1.1
	dir3d = dir3d.lerp(target, _elevationPercentage)
	var newPosition = global_position + dir3d * mon.grabBody.grabDistance
	mon.grabBody.global_position = newPosition

func onMonigoteGrabbed():
	mon.escapeMovements = 0
	mon.invincible = true

func onGrabGraceTimeTimeout():
	if not mon.grabbing:
		onPushed()

func onGrabAreaBodyEntered(body):
	if $GrabGraceTime.is_stopped() or not body is Pushable:
		return
	
	if mon.startGrab(body):
		mon.emit_signal("grab", body)

func pushAnimation():
	var tween := mon.grabBody.create_tween()
	var dir3d := Vector3(mon.grabDir.x, 0, mon.grabDir.y).normalized()
	var displacement := forcePercentage * .5
	tween.tween_property(mon.grabBody, "global_position", -displacement*dir3d, .08).as_relative()
	tween.tween_interval(.2*forcePercentage)
	tween.tween_property(mon.grabBody, "global_position", 2*displacement*dir3d, .05).as_relative()
	tween.tween_callback(mon.push)
