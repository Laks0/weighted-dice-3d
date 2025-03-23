extends MonigoteAnimation3D

@export_range(0,PI/8) var minAngleFromFloor := PI/8

@onready var currentRotationRaycast : RayCast3D = $RotationRaycastNoSignal

var uniformScale := .5

func _ready():
	play()

## Retorna la dirección normalizada ideal de billboard según la cámara actual, ignorando colisiones
func getTrueBillboardDirection() -> Vector3:
	var noXCameraPos := get_viewport().get_camera_3d().global_position * Vector3(0,1,1)\
		+ global_position * Vector3(1,0,0)
	var dirToCamera := global_position.direction_to(noXCameraPos)
	return dirToCamera.rotated(Vector3.LEFT, PI/2)

## Retorna la dirección normalizada a la que debería ir el sprite teniendo en cuenta colisiones
func getTargetDirection() -> Vector3:
	if not currentRotationRaycast.is_colliding():
		return getTrueBillboardDirection()
	
	var collisionPoint = currentRotationRaycast.get_collision_point()
	var wallPointWithoutY := to_local(collisionPoint) * Vector3(1,0,1)
	var floorDistanceToCollisionSquared : float = wallPointWithoutY.length_squared()
	var rayLengthSquared : float = (currentRotationRaycast.target_position*2).length_squared()
	# o² = h² - a²
	var newHeadHeight := sqrt(rayLengthSquared - floorDistanceToCollisionSquared)
	var newLocalYAxis := wallPointWithoutY + Vector3.UP * newHeadHeight
	
	return newLocalYAxis.normalized()

func updateSpriteHeight():
	var defaultFeetHeight : float = -$RotationRaycastNoSignal.target_position.length()
	var currentFeetPosition := animatedSprite.basis.y.normalized() * defaultFeetHeight
	animatedSprite.position.y = (defaultFeetHeight - currentFeetPosition.y) * (animatedSprite.scale.y)

func physicsUpdate(_delta):
	rotation = -animatedSprite.rotation
	
	if mon.grabbed:
		return
	
	var targetDirection := getTargetDirection()
	
	var directionOfMinAngle := Vector3.FORWARD.rotated(Vector3.RIGHT, minAngleFromFloor)
	var minDotFromFloor := Vector3.FORWARD.dot(directionOfMinAngle)
	if (not targetDirection.is_finite()) or Vector3.FORWARD.dot(targetDirection) > minDotFromFloor:
		targetDirection = directionOfMinAngle
	
	resultBasis.y = uniformScale * (targetDirection * Vector3(0,1,1)).normalized()
	resultBasis.z = animatedSprite.basis.y.rotated(Vector3.RIGHT, PI/2)
	resultBasis.x = uniformScale * Vector3.RIGHT
	
	updateSpriteHeight()

func _process(_delta):
	var trueBillboard := getTrueBillboardDirection()
	var rayLength := currentRotationRaycast.target_position.length()
	currentRotationRaycast.target_position = trueBillboard * rayLength

func _onAnimatedSpriteSet():
	uniformScale = animatedSprite.scale.y

func onBetSignalSatatusChanged(isVisible : bool):
	currentRotationRaycast = $RotationRaycastSignal if isVisible else $RotationRaycastNoSignal
	currentRotationRaycast.enabled = true

func onMonigoteGrab(body : Pushable):
	$RotationRaycastNoSignal.add_exception(body)
	$RotationRaycastSignal.add_exception(body)

func onMonigotePushed():
	$RotationRaycastNoSignal.clear_exceptions()
	$RotationRaycastSignal.clear_exceptions()
