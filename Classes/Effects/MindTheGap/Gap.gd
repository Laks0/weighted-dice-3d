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
	if mon.invincible:
		return
	
	$YellVoid.play()
	
	$Sprite.play("BW")
	
	# Animación del monigote
	mon.set_process(false)
	mon.set_physics_process(false)
	mon.position.y = monigoteFallHeight
	var fallTween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	fallTween.tween_property(mon, "position:y", 0, .5)
	fallTween.tween_callback(func ():
		mon.set_physics_process(true)
		mon.set_process(true)
		mon.hurt()
		queue_free())
