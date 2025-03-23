extends Node3D

@export var mon : Monigote
@export var sprite : AnimatedSprite3D
@export var grabDistance : float = .66

@onready var restPositionR := Vector3(-$RestL.position.x, $RestL.position.y, $RestL.position.z)
@onready var readyPositionR := Vector3(-$ReadyL.position.x, $ReadyL.position.y, $ReadyL.position.z)

var closed := false
var direction : Vector2
var grabBody : Pushable

func _ready():
	$L.material_override.set_shader_parameter("swap_to", mon.player.id)

func _process(_delta):
	$L.rotation = sprite.rotation
	$R.rotation = sprite.rotation
	$L.rotation.z = -direction.angle() - PI/2
	$R.rotation.z = -direction.angle() - PI/2
	if closed:
		direction = mon.grabDir
		$L.position = _getClosedPositionL()
		$R.position = _getClosedPositionR()

func _canUseGrabBody() -> bool:
	return closed and is_instance_valid(grabBody)

func _centerPosition() -> Vector3:
	if _canUseGrabBody():
		return to_local(grabBody.global_position)
	var direction3d := Vector3(direction.x, 0, direction.y)
	return direction3d * grabDistance

func _handDifference() -> Vector3:
	return Vector3(-direction.y, 0, direction.x) * (.1 if not _canUseGrabBody() else .3)

func _getClosedPositionL() -> Vector3:
	return _centerPosition() - _handDifference()

func _getClosedPositionR() -> Vector3:
	return _centerPosition() + _handDifference()

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
	$L.play()
	$R.play()
	direction = mon.grabDir
	var tween := create_tween()
	tween.tween_property($L, "position", _getClosedPositionL(), time)
	tween.parallel().tween_property($R, "position", _getClosedPositionR(), time)

func goToRest(time : float) -> void:
	$L.play_backwards()
	$R.play_backwards()
	closed = false
	var tween := create_tween()
	var waitTime = time/2
	var backTime = time - waitTime
	tween.tween_interval(waitTime)
	tween.tween_property($L, "position", $RestL.position, backTime)
	tween.parallel().tween_property($R, "position", restPositionR, backTime)
	await tween.finished
	visible = false

func onPush(cooldownTime : float) -> void:
	var pushTime := .05
	var diff := Vector3(direction.x, 0, direction.y) * mon.pushFactor
	var pushTween := create_tween().set_parallel()
	pushTween.tween_property($L, "position", diff, pushTime).as_relative()
	pushTween.tween_property($R, "position", diff, pushTime).as_relative()
	pushTween.chain().tween_callback(goToRest.bind(cooldownTime - pushTime))

func startGrabbing(body):
	closed = true
	grabBody = body
