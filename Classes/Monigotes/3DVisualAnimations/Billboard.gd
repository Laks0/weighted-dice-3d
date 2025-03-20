extends MonigoteAnimation3D

############
# Rotación
############

### Retorna cuál debería ser la rotación en el eje x del sprite en su posición, con el efecto
### secundario de rotar el raycast lo que sea necesario
#func _getCustomBillboardYAxis() -> Vector3:
	## Billboard normal
	#var noXCameraPos := get_viewport().get_camera_3d().global_position * Vector3(0,1,1)
	#noXCameraPos += global_position * Vector3(1,0,0)
	#var dirToCamera := global_position.direction_to(noXCameraPos)
	#var cameraUp := dirToCamera.rotated(Vector3.LEFT, PI/2)
	#
	##if not currentRotationRaycast.is_colliding():
	#currentRotationRaycast.rotation.x = 0
	#return cameraUp.normalized() * basis.y.length()
	#
	#var collisionPoint : Vector3 = currentRotationRaycast.get_collision_point()
	#var wallPointWithoutY := to_local(collisionPoint) * Vector3(1,0,1)
	#var squaredFloorDistanceToCollision := wallPointWithoutY.length_squared()
	#var rayLengthSquared : float = currentRotationRaycast.target_position.length_squared()
	#
	## o² = √(h²-a²)
	#var newHeadHeight := sqrt(rayLengthSquared - squaredFloorDistanceToCollision)
	#var newLocalY := wallPointWithoutY + Vector3.UP * newHeadHeight
	#currentRotationRaycast.rotation.x += to_local(collisionPoint).angle_to(newLocalY)
	#return newLocalY.normalized() * basis.y.length()
#
#var transitioningRotation := false
#var rotationAnimationTreshold := PI/8 # La máxima cantidad que se puede rotar en un frame sin tween
### Rota el sprite como billboard a menos que se choque contra un cuerpo
#func billboardUpdate():
	##if transitioningRotation:
		##return
	##
	##var newRotation = 0#_getNewRotation()
	##
	### Reajuste de altura
	##var spriteHalfHeight := .05
	##var feetHeight := cos(newRotation) * spriteHalfHeight
	##
	### Si la rotación nueva es lo suficientemente parecida se puede pasar en un solo frame
	##if abs(newRotation - rotation.x) < rotationAnimationTreshold:
		##position.y = feetHeight
		##rotation.x = newRotation
		##return
	##
	### Si no, se anima la rotación
	##transitioningRotation = true
	##var tween = create_tween().set_parallel(true)
	##var time := .08
	##tween.tween_property(self, "rotation:x", newRotation, time)
	##tween.tween_property(self, "position:y", feetHeight, time)
	##
	##await tween.finished
	##
	##transitioningRotation = false
	#basis.y = _getCustomBillboardYAxis()

func physicsUpdate(delta):
	if mon.grabbed:
		pass
