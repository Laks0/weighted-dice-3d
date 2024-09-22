extends Area3D

func onBodyEntered(body):
	if body is ReadyChip:
		body.queue_free()
		get_parent().emit_signal("monigoteReady", body.monigote)
