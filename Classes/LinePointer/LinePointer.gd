extends Node3D

func point(from : Vector3, to : Vector3):
	if from.is_equal_approx(to):
		return
	
	$Mesh.mesh.height = from.distance_to(to)
	$Mesh.mesh.material.set_shader_parameter("size", $Mesh.mesh.height)
	global_position = lerp(from, to, .5)
	look_at(to)
	rotate_object_local(Vector3.RIGHT, PI/2)

func setWidth(meters : float):
	$Mesh.mesh.top_radius = meters
	$Mesh.mesh.bottom_radius = meters

func setSpeed(speed : float):
	$Mesh.mesh.material.set_shader_parameter("speed", speed)

func freezeAnimation():
	setSpeed(0)
