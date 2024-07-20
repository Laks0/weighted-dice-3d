extends StaticBody3D

@export var throwForce : float = 20

func _on_area_3d_body_entered(body):
	if not body is Monigote:
		return
	
	body.knockbackFrom(position, throwForce)
	
	# Aleja el monigote por si se queda atrapado adentro de la torre
	var distance := position.distance_to(body.position)
	var radius : float = $Area3D/CollisionShape3D.shape.radius
	
	if distance > radius:
		return
	
	var dir := position.direction_to(body.position)
	body.position = position + dir * radius
