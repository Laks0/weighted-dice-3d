extends Control

signal finished

var controllerId : int = Controllers.KB
var actionSelected : String = ""

@export var buttonActionMap : Dictionary

func setControllerId(id : int):
	for button : GamepadSelectButton in %VBoxContainer.get_children():
		button.controller = id
	
	controllerId = id

func inputNameFromAction(actionName : StringName) -> StringName:
	var names : Array = InputMap.action_get_events(actionName).map(singularInputToString)
	return " / ".join(names)

func getStickDirectionName(inputName : StringName) -> StringName:
	if inputName.contains("Y") and inputName.contains("-1"):
		return "up"
	if inputName.contains("Y") and inputName.contains("1"):
		return "down"
	if inputName.contains("X") and inputName.contains("-1"):
		return "left"
	if inputName.contains("X") and inputName.contains("1"):
		return "right"
	return ""

func singularInputToString(input : InputEvent) -> StringName:
	# Para teclado
	if controllerId in [Controllers.KB, Controllers.KB2]:
		return input.as_text().split(" (")[0]
	
	# Para controles
	
	# Si es un botón
	var xboxRegex := RegEx.new()
	xboxRegex.compile("Xbox \\w+")
	var result := xboxRegex.search(input.as_text())
	
	if result:
		return result.get_string()
	
	# Si es un D-Pad
	var dpadRegex := RegEx.new()
	dpadRegex.compile("D-pad \\w+")
	result = dpadRegex.search(input.as_text())
	
	if result:
		return result.get_string()
	
	# Si es un stick
	var stick := RegEx.new()
	stick.compile("\\w+ Stick")
	result = stick.search(input.as_text())
	
	if result:
		return result.get_string() + " " + getStickDirectionName(input.as_text())
	
	return input.as_text()

func _process(_delta):
	var actions := Controllers.getActions(controllerId)
	if actions.has(actionSelected):
		%ActionLabel.text = inputNameFromAction(actions[actionSelected])
	else:
		%ActionLabel.text = ""
	
	if actionSelected == "Movement":
		%ActionLabel.text += "Arriba\n"+inputNameFromAction(actions.up)+"\n"
		%ActionLabel.text += "Abajo\n"+inputNameFromAction(actions.down)+"\n"
		%ActionLabel.text += "Izquierda\n"+inputNameFromAction(actions.left)+"\n"
		%ActionLabel.text += "Derecha\n"+inputNameFromAction(actions.right)+"\n"

func onOKPressed():
	finished.emit()

func onMovementFocus():
	actionSelected = "Movement"

func onGrabFocus():
	actionSelected = "grab"

func onPauseFocus():
	actionSelected = "pause"

func onOKFocus():
	actionSelected = "OK"
