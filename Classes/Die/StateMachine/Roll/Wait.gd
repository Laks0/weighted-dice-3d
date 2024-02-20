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
	
	target.emit_signal("rolled", result)
	
	await get_tree().create_timer(target.timeAfterRoll).timeout
	
	get_parent().change_state("RandomAttack")
