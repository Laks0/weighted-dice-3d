extends RayCast3D

var telegraphing := false

func _process(delta):
	if not telegraphing:
		position = Vector3.ZERO
		return
	
	position += target_position * delta * 3
	
	if is_colliding() and get_collider().is_in_group("Walls"):
		target_position = target_position.bounce(get_collision_normal())

func startTelegraphing():
	position = Vector3.ZERO
	$GPUParticles3D.emitting = true
	telegraphing = true
	$GPUParticles3D.visible = true

func endTelegraphing():
	position = Vector3.ZERO
	$GPUParticles3D.emitting = false
	telegraphing = false
	$GPUParticles3D.visible = false
