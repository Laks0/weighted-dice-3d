extends Node3D

func _rotateWheelTo(wheelN : int, n : int):
	var wheel : Node3D = get_node("Wheel_" + str(wheelN))
	var currentN := _getWheelCurrentFace(wheel)

	var rotationTween := create_tween()
	var deltaRotation = PI/5 * posmod((n - currentN), 10)
	rotationTween.tween_property(wheel, "rotation:x", wheel.rotation.x + deltaRotation, .1)

## Las ruedas empiezan en PI/10 y giran PI/5 por cada número
func _getWheelCurrentFace(wheel : Node3D) -> int:
	return (wheel.rotation.x - PI/10) / (PI/5)
