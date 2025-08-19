extends Area3D

@export var atractAcceleration := 300

var rayDir := Vector3(PI/100, 0, 0)

func _process(delta):
	rayDir.y += PI/4 * delta
	
	$Spotlight.rotation = rayDir
	
	for i in get_tree().get_nodes_in_group("Monigotes"):
		var mon := i as Monigote
		if not isOnRay(mon):
			continue
		var dir3D = mon.position.direction_to(position)
		var dist = 2/mon.position.distance_to(position)
		mon.movement.applyAcceleraction(Vector2(dir3D.x, dir3D.z).normalized() * atractAcceleration * dist)

func isOnRay(mon : Monigote):
	var dir2d := Vector2.from_angle(-rayDir.y - PI/2)
	var pos2d := Vector2(mon.position.x, mon.position.z).normalized()
	
	var angle := dir2d.angle_to(pos2d)
	return angle < PI/4 and angle > -PI/4

func _on_animated_sprite_3d_animation_finished():
	if $AnimatedSprite3D.animation == "Spawn":
		$AnimatedSprite3D.play("Loop")
		monitoring = true
	if $AnimatedSprite3D.animation == "DeSpawn":
		queue_free()

func _on_body_entered(body):
	if body is Monigote:
		body.die()

func kill():
	var lightTween := get_tree().create_tween()
	lightTween.tween_property($Spotlight, "light_energy", 0, .4)
	lightTween.set_ease(Tween.EASE_OUT)
	set_deferred("monitoring", false)
	$AnimatedSprite3D.play("DeSpawn")
