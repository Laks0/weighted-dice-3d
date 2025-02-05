extends Control

signal finished

var controllerId : int = 0
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

var actions : Dictionary

func _process(_delta):
	if editting:
		%ActionLabel.text = "Apretá algún botón"

		if actionSelected == "up":
			%ActionLabel.text = "Seleccioná un input para arriba"
		elif actionSelected == "down":
			%ActionLabel.text = "Seleccioná un input para abajo"
		elif actionSelected == "left":
			%ActionLabel.text = "Seleccioná un input para la izquierda"
		elif actionSelected == "right":
			%ActionLabel.text = "Seleccioná un input para la derecha"

		%Instrucciones.text = ""
		return
	
	actions = Controllers.getActions(controllerId)
	if actions.has(actionSelected):
		%ActionLabel.text = inputNameFromAction(actions[actionSelected])
	else:
		%ActionLabel.text = ""
	
	if actionSelected == "up":
		%ActionLabel.text  = "Arriba\n"+inputNameFromAction(actions.up)+"\n"
		%ActionLabel.text += "Abajo\n"+inputNameFromAction(actions.down)+"\n"
		%ActionLabel.text += "Izquierda\n"+inputNameFromAction(actions.left)+"\n"
		%ActionLabel.text += "Derecha\n"+inputNameFromAction(actions.right)+"\n"

	%Instrucciones.text = inputNameFromAction(actions.up) + " para arriba " + inputNameFromAction(actions.down) + " para abajo " + inputNameFromAction(actions.grab) + " para seleccionar"

func onOKPressed():
	finished.emit()

func setAction(action : StringName):
	actionSelected = action

var editting := false
func startEdit():
	await get_tree().process_frame
	editting = true
	%VBoxContainer.visible = false
	InputMap.action_erase_events(actions[actionSelected])
	if actionSelected == "up":
		InputMap.action_erase_events(actions["down"])
		InputMap.action_erase_events(actions["left"])
		InputMap.action_erase_events(actions["right"])

func handleButtonInput(event : InputEvent, actionName : StringName):
	if not event.is_pressed():
		return
	
	changeAction(event, actionName)

func handleJoypadMotion(event : InputEventJoypadMotion, actionName : StringName):
	if abs(event.axis_value) < .5:
		return
	
	event.axis_value = signf(event.axis_value)
	changeAction(event, actionName)

func changeAction(event : InputEvent, actionName : StringName):
	InputMap.action_add_event(actions[actionName], event)

	if actionSelected == "up":
		actionSelected = "down"
	elif actionSelected == "down":
		actionSelected = "left"
	elif actionSelected == "left":
		actionSelected = "right"
	else:
		if actionSelected == "right":
			actionSelected = "up"
		editting = false
		%VBoxContainer.visible = true

func _input(event : InputEvent):
	if not editting:
		return
	
	# No se puede mapear un input que ya está mapeado en otro lado
	# Las acciones que pueden contradecir a esta
	var actionsToCheck := actions.values()
	if controllerId in [Controllers.KB, Controllers.KB2]:
		actionsToCheck = Controllers.getActions(Controllers.KB).values()
		actionsToCheck.append_array(Controllers.getActions(Controllers.KB2).values())

	# Por cada una de las acciones, verificar que no hay ninguna que coincida
	for actionName : StringName in actionsToCheck:
		if not event.is_action(actionName):
			continue
		# Los eventos de movimiento de joypad coinciden también en direcciones opuestas
		if event is InputEventJoypadMotion:
			for actionEvent : InputEvent in InputMap.action_get_events(actionName):
				if not actionEvent is InputEventJoypadMotion:
					continue
				if signf(actionEvent.axis_value) == signf(event.axis_value):
					return
			continue

		return


	if event is InputEventKey and controllerId in [Controllers.KB, Controllers.KB2]:
		handleButtonInput(event, actionSelected)
		return
	
	if controllerId in [Controllers.KB, Controllers.KB2] or event.device != controllerId:
		return
	
	if event is InputEventJoypadButton:
		handleButtonInput(event, actionSelected)
	elif event is InputEventJoypadMotion:
		handleJoypadMotion(event, actionSelected)
