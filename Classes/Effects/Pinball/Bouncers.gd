extends Area3D

func _on_body_shape_entered(_body_rid, body, _body_shape_index, local_shape_index):
	if not body is Pushable:
		return
	
	var local_shape_owner = shape_find_owner(local_shape_index)
	var collisionNode : CollisionShape3D = shape_owner_get_owner(local_shape_owner)
	
	# La rotación de collisionNode determina la normal
	var normal : Vector3
	
	if collisionNode.rotation.y == 0:
		normal = Vector3(0,0,1)
	else:
		normal = Vector3(1,0,0)
	
	body.bounce(normal)
