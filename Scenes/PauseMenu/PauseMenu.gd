extends Control

var pausedController : int
var isPaused : bool = false #Esto me resultó necesario para hacer los sonidos de pausa
# y despausa porque las funciones start y end Pause ambas se disparan a la vez siempre que se (des)pausa
func startPause(controllerId : int):
	var player := PlayerHandler.getPlayerByController(controllerId)
	if player == null:
		return
	get_tree().set_pause(true)
	pausedController = controllerId
	$Menu/PlayerName.text = "Pausado por " + player.name
	$Menu/PlayerName.modulate = player.color
	
	for button : GamepadSelectButton in %Buttons.get_children():
		button.controller = controllerId
	%ConfigControllers.setControllerId(controllerId)
	
	visible = true
	if !isPaused && !$Unpause.playing:
		$Pause.play()
		isPaused = true
	elif isPaused && !$Pause.playing:
		$Unpause.play()
		isPaused = false

func endPause():
	get_tree().set_pause(false)
	visible = false

func startEditting():
	await get_tree().process_frame
	%Buttons.visible = false
	%ConfigControllers.visible = true
	%ConfigControllers.restart()

func stopEditting():
	await get_tree().process_frame
	%Buttons.visible = true
	%ConfigControllers.visible = false

func _ready():
	visible = false

func _input(event : InputEvent):
	if %ConfigControllers.visible:
		return
	
	for id in Controllers.controllers.keys():
		if not event.is_action_pressed(Controllers.getActions(id)["pause"]):
			continue
		
		if not get_tree().is_paused():
			startPause(id)
			break
		
		if id == pausedController:
			endPause()
		
		break
