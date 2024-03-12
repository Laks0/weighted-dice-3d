@tool
extends State

var direction : Vector2

func _on_enter(_args):
	target.prepareArrow.visible = true
	direction = Vector2.ZERO
	
	if not PlayerHandler.isGameOnline or multiplayer.is_server():
		direction = target._getRandomMonigoteDirection()
		_syncDirection.rpc(direction)
	else:
		while direction == Vector2.ZERO:
			await get_tree().process_frame
	
	var angle = -direction.angle()
	const OFFSET = -PI/2
	target.prepareArrow.rotation.y = angle + OFFSET

func _state_timeout():
	change_to_next(direction)

func _on_exit(_args):
	target.prepareArrow.visible = false

@rpc("authority", "call_remote", "reliable")
func _syncDirection(dir : Vector2):
	direction = dir
