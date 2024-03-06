extends Pushable
class_name PoolStick

func _on_area_3d_body_entered(body):
	if body is Ball8 and (grabbed or not velocity.is_zero_approx()):
		body.direction = position.direction_to(body.position) * Vector3(1,0,1)

func _physics_process(delta):
	super(delta)
	$Sprite3D.modulate = color
