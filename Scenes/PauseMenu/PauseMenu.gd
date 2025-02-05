extends Control

var pausedController : int

func startPause(controllerId : int):
	get_tree().set_pause(true)
	pausedController = controllerId
	var player := PlayerHandler.getPlayerByController(controllerId)
	$Menu/PlayerName.text = "Pausado por " + player.name
	$Menu/PlayerName.modulate = player.color
	visible = true

func endPause():
	get_tree().set_pause(false)
	visible = false

func _ready():
	visible = false

func _input(event : InputEvent):
	print(event.as_text())
	for id in Controllers.controllers.keys():
		if not event.is_action_pressed(Controllers.getActions(id)["pause"]):
			continue
		
		if not get_tree().is_paused():
			startPause(id)
			break
		
		if id == pausedController:
			endPause()
		
		break
