extends Effect

@export var ball8Scene : PackedScene
var ball8 : StaticBody3D

func start():
	ball8 = ball8Scene.instantiate()
	
	ball8.set_physics_process(false)
	arena.add_child(ball8)
	
	$AnimationPlayer.play("BallEnter")
	$AnimationPlayer.animation_finished.connect(func (_anim):
		if not is_instance_valid(ball8):
			return
		ball8.set_physics_process(true))
	
	$SpotLight3D.visible = true
	$SpotLight3D.light_energy = 0
	create_tween().tween_property($SpotLight3D, "light_energy", 11, .2)

func _process(_delta):
	if not is_instance_valid(ball8):
		return
	
	if $AnimationPlayer.is_playing():
		ball8.position = $BallAnimationPos.position
	
	var targetDir = $SpotLight3D.position.direction_to(ball8.position)
	var targetBasis = Basis.looking_at(targetDir)
	$SpotLight3D.basis = $SpotLight3D.basis.slerp(targetBasis, .1)

func end():
	if is_instance_valid(ball8):
		ball8.queue_free()
	
	var tween := create_tween()
	tween.tween_property($SpotLight3D, "light_energy", 0, .2)
	tween.tween_callback(func(): $SpotLight3D.visible = false)
