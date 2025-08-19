extends Area3D
class_name Gap

@export var monigoteFallHeight := 6.0

func delete():
	$Sprite.play("BW")
	$Sprite.animation_finished.connect(queue_free)

func _on_sprite_animation_finished():
	if $Sprite.animation == "FW": # Animación de entrada
		$Collision.disabled = false

func _on_body_entered(body):
	if not body is Monigote:
		return
	var mon := body as Monigote
	if mon.invincible or body.velocity.y > 0:
		return
	
	mon.movement.resetMovement()
	$YellVoid.play()
	
	$Sprite.play("BW")
	$Collision.queue_free()
	
	# Animación del monigote
	mon.freeze()
	mon.position.y = monigoteFallHeight
	var fallTween := mon.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	fallTween.tween_property(mon, "position:y", Globals.SPRITE_HEIGHT, .5)
	fallTween.tween_callback(func ():
		mon.unfreeze()
		mon.hurt())
	
	await fallTween.finished
	queue_free()
