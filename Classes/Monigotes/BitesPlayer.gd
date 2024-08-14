extends AudioStreamPlayer3D

@onready var player : PlayerHandler.Player = get_parent().player

func bitePlay(category : String):
	stream = player.getBiteStream(category)
	play()

func onMonigoteGrab(_body):
	bitePlay("grab")

func _on_monigote_pushed():
	bitePlay("throwc")

func _on_monigote_was_pushed(_dir, factor, _pusher):
	if factor == 1:
		bitePlay("thrown") #cambiar cuando haya tiro largo
	else:
		bitePlay("thrown")

func _on_monigote_was_hurt():
	bitePlay("hit")

func _on_monigote_died():
	bitePlay("dead")


func _on_monigote_has_won():
	await get_tree().create_timer(.6).timeout
	bitePlay("victory")
