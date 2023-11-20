extends StaticBody3D
class_name Spike

func _on_area_3d_body_entered(body):
	if body is Monigote:
		var mon = body as Monigote
		mon.stun()
		mon.knockback(-Vector2(mon.velocity.x, mon.velocity.z)*2)
		
