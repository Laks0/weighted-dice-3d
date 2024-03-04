@tool
extends State

var result : int
var effectStarted : bool

func _on_enter(res) :
	result = res
	effectStarted = false

func _on_update(_delta):
	if (not target.onFloor()) or effectStarted:
		return
	
	effectStarted = true
	
	target.axis_lock_angular_x = false
	target.axis_lock_angular_y = false
	target.axis_lock_angular_z = false
	
	var particles : GPUParticles3D = target.get_node("StompParticles")
	target.get_node("Stomp").play()
	# Hace que las partículas apunten hacia abajo, ignorando la rotación del dado
	particles.rotation = -target.rotation
	particles.rotation.y = 0
	
	particles.emitting = true
	
	# Luz del número que salió
	var light : OmniLight3D = target.get_node("NumberLight")
	light.global_position = target.global_position + Vector3.UP
	
	var lightTween = create_tween()
	lightTween.tween_interval(.4)
	lightTween.tween_property(light, "light_energy", 1.5, target.timeAfterRoll/2-.4)
	lightTween.tween_property(light, "light_energy", 0, target.timeAfterRoll/2)
	
	target.emit_signal("rolled", result)
	
	if result == 5:
		target.get_parent().lightsOff()
	
	await get_tree().create_timer(target.timeAfterRoll).timeout
	
	if result != 5:
		get_parent().change_state("RandomAttack")
	else:
		change_to_next()
