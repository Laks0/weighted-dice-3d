extends StaticBody3D

@export var throwForce : float = 20

func _on_area_3d_body_entered(body):
	if not body is Monigote:
		return
	
	body.knockbackFrom(position, throwForce)
