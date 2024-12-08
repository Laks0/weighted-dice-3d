extends Node3D

@export var mon : Monigote
@export var sprite : AnimatedSprite3D
@export var grabDistance : float = .66

@onready var restPositionR := Vector3(-$RestL.position.x, $RestL.position.y, $RestL.position.z)
@onready var readyPositionR := Vector3(-$ReadyL.position.x, $ReadyL.position.y, $ReadyL.position.z)

var closed := false
var direction : Vector2
var grabBody : Pushable

func _process(_delta):
	$L.rotation = sprite.rotation
	$R.rotation = sprite.rotation
	if closed:
		direction = mon.grabDir
		$L.position = _getClosedPositionL()
		$R.position = _getClosedPositionR()

func _planePosition() -> Vector2:
	return direction * (grabDistance if not closed else grabBody.grabDistance)

func _handDifference() -> Vector2:
	return Vector2(-direction.y, direction.x) * (0 if not closed else grabBody.grabDistance*.9)

func _getClosedPositionL() -> Vector3:
	var planePosition := _planePosition()
	planePosition -= _handDifference()
	return Vector3(planePosition.x, 0, planePosition.y)

func _getClosedPositionR() -> Vector3:
	var planePosition := _planePosition()
	planePosition += _handDifference()
	return Vector3(planePosition.x, 0, planePosition.y)

func attack(time : float) -> void:
	$R.position = restPositionR
	$L.position = $RestL.position
	
	var prepareTime := time/3
	var holdTime := time/3
	var attackTime := time - holdTime - prepareTime
	
	visible = true
	var tween := create_tween()
	tween.tween_property($L, "position", $ReadyL.position, prepareTime)
	tween.parallel().tween_property($R, "position", readyPositionR, prepareTime)
	
	tween.tween_interval(holdTime)
	tween.tween_callback(_goToPosition.bind(attackTime))

func _goToPosition(time : float):
	direction = mon.grabDir
	var tween := create_tween()
	tween.tween_property($L, "position", _getClosedPositionL(), time)
	tween.parallel().tween_property($R, "position", _getClosedPositionR(), time)

func go_to_rest(time : float) -> void:
	closed = false
	var tween := create_tween()
	var waitTime = time/4
	var backTime = time - waitTime
	tween.tween_interval(waitTime)
	tween.tween_property($L, "position", $RestL.position, backTime)
	tween.parallel().tween_property($R, "position", restPositionR, backTime)
	await tween.finished
	visible = false

func startGrabbing(body):
	closed = true
	grabBody = body
