@tool
extends State

var direction : Vector2

func _on_enter(_args):
	get_parent().bursts += 1
	target.prepareArrow.visible = true
	
	direction = target._getRandomMonigoteDirection()
	var angle = -direction.angle()
	const OFFSET = -PI/2
	target.prepareArrow.rotation.y = angle + OFFSET

func _state_timeout():
	change_to_next(direction)

func _on_exit(_args):
	target.prepareArrow.visible = false
