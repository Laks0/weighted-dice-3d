extends MeshInstance3D

func point(from : Vector3, to : Vector3):
	if from.is_equal_approx(to):
		return
	
	scale.y = from.distance_to(to)
	mesh.material.set_shader_parameter("size", scale.y)
	global_position = (to+from)*.5
	look_at(to)
	rotate_x(PI/2)
