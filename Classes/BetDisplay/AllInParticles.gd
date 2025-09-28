extends Node3D

var playerId : int = 0

func _ready():
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.2).timeout #Sepa disculpar lakso, es una forma mala pero rápida de que las partículas coincidan mas o menos con la caida de la ficha
	$GPUParticles3D.draw_pass_1.material.albedo_color = PlayerHandler.getSkinColor(playerId)
	$GPUParticles3D.emitting = true
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($Label3D, "scale", Vector3.ONE, .5).from(Vector3.ZERO)
	tween.tween_interval(.4)
	tween.tween_property($Label3D, "scale", Vector3.ZERO, .5)
	tween.tween_callback(queue_free)
	
