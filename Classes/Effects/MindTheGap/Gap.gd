extends Area3D
class_name Gap

func delete():
	$Sprite.play("BW")

func _on_sprite_animation_finished():
	if $Sprite.animation == "FW": # Animación de entrada
		$Collision.disabled = false
	elif $Sprite.animation == "BW": # Animación de salida
		queue_free()

func _on_body_entered(body):
	if not body is Monigote:
		return
	var mon := body as Monigote
	
	$YellVoid.play()
	
	mon.die()
	delete()
