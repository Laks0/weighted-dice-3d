extends RigidBody3D
class_name Die

@export var rotations : PackedVector3Array

func throw(impulse : Vector3):
	apply_central_impulse(impulse)
	var torque := Vector3(randf(), randf(), randf()).normalized()
	apply_torque_impulse(torque * 10)
