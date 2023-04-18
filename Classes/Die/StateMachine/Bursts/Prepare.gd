@tool
extends State

var direction : Vector2

func _on_enter(_args):
	target.prepareArrow.visible = true
	
	direction = target._getRandomMonigoteDirection()
	var angle = -direction.angle()
	const OFFSET = -PI/2
	target.prepareArrow.rotation.y = angle + OFFSET

func _state_timeout():
	change_state("Burst", direction)

func _on_exit(_args):
	target.prepareArrow.visible = false
