extends Node3D

signal finishedAnimation

@export var rigidBall : PackedScene

## Recibe el monigote que tiene que sacar y a dónde en la pantalla tiene que ir
func chooseMonigote(skin : int, target2dPos : Vector2):
	var color = PlayerHandler.getSkinColor(skin)
	
	var monigoteBall : MeshInstance3D = $Gacha/PelotaMonigote
	
	# Animación de gacha
	$Gacha/AnimationPlayer.play("Pelota")
	monigoteBall.visible = true
	
	# El SFX empieza .7 segundos después (Hack)
	get_tree().create_timer(.7).timeout.connect($GachaSFX.play)
	
	await get_tree().create_timer(1.7).timeout
	# Animación de pelotas
	monigoteBall.get_surface_override_material(0).albedo_color = color
	
	var closestBall = $RigidBalls.get_children()\
	.reduce(func (closest : RigidBody3D, ball : RigidBody3D):
		if closest == null:
			return ball
		var closestDistance : float = closest.global_position.distance_to($Gacha/Hole.global_position)
		var ballDistance : float = ball.global_position.distance_to($Gacha/Hole.global_position)
		
		if ballDistance <= closestDistance:
			return ball
		return closest
	)
	
	closestBall.id = skin
	
	var ballPosTween = create_tween()
	ballPosTween.tween_property(closestBall, "position", Vector3(0, -.5, 0), .1).as_relative()
	ballPosTween.tween_callback(closestBall.queue_free)
	
	await $Gacha/AnimationPlayer.animation_finished
	
	# Cambio de pelota
	var chosenBall = rigidBall.instantiate()
	chosenBall.global_transform = monigoteBall.global_transform.scaled(Vector3.ONE * 2.78)
	chosenBall.position = $MonigoteBallPosition.position
	chosenBall.freeze = true
	add_child(chosenBall)
	chosenBall.id = skin
	
	await get_tree().create_timer(.1).timeout
	
	monigoteBall.visible = false
	
	var animTween := create_tween().set_parallel(true)
	animTween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	animTween.tween_property(chosenBall, "global_position", 
		$MultipleResCamera.project_position(target2dPos, 20), .5)
	animTween.tween_property(chosenBall, "rotation", Vector3.ZERO, .5)
	# SFX de saludo del monigote
	animTween.chain().tween_callback(func ():
		var player = PlayerHandler.getPlayerById(skin)
		await get_tree().create_timer(.3).timeout
		Narrator.playBank("charsel_" + PlayerHandler.getPlayerById(skin).name.to_lower())
		$BallsSFX.stream = player.getBiteStream("salute")
		await get_tree().create_timer(.5).timeout
		$BallsSFX.play()
	)
	
	chosenBall.startAnimation()
	
	animTween.chain().tween_callback(emit_signal.bind("finishedAnimation"))
