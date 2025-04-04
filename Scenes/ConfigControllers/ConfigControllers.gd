extends Control

signal finished

@onready var controllerId : int = Controllers.KB
var actionSelected : String = ""
var actions : Dictionary
var actionChanges : Dictionary[String, InputEvent]

func setControllerId(id : int):
	for c : GamepadSelectButton in $HBoxContainer.get_children():
		c.controller = id
	$GamepadSelectCarousel.controller = id
	
	controllerId = id

func inputNameFromAction(actionName : StringName) -> StringName:
	var actionEvents : Array[InputEvent] = InputMap.action_get_events(actions[actionName])
	if actionChanges.has(actionName):
		actionEvents = [actionChanges[actionName]]
	var names : Array = actionEvents.map(singularInputToString)
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
		return
	
	setAction($GamepadSelectCarousel.getSelectedId())
	
	actions = Controllers.getActions(controllerId)
	if actions.has(actionSelected):
		%ActionLabel.text = inputNameFromAction(actionSelected)
	else:
		%ActionLabel.text = ""
	
	if actionSelected == "up":
		%ActionLabel.text  = "Arriba: "+inputNameFromAction("up")+"    "
		%ActionLabel.text += "Abajo: "+inputNameFromAction("down")+"\n"
		%ActionLabel.text += "Izquierda: "+inputNameFromAction("left")+"    "
		%ActionLabel.text += "Derecha: "+inputNameFromAction("right")+"\n"
	
	if actionChanges.is_empty():
		%Back.visible = true
		%Cancel.visible = false
		%Accept.visible = false
	else:
		%Back.visible = false
		%Cancel.visible = true
		%Accept.visible = true

func setAction(action : StringName):
	actionSelected = action

var editting := false
func startEdit():
	$HBoxContainer.visible = false
	await get_tree().process_frame
	editting = true

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
	actionChanges[actionName] = event
	
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
		$HBoxContainer.visible = true

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

func cancelChanges():
	actionChanges.clear()
	finished.emit()

func applyChanges():
	for actionName : StringName in actionChanges.keys():
		InputMap.action_erase_events(actions[actionName])
		InputMap.action_add_event(actions[actionName], actionChanges[actionName])
	actionChanges.clear()
	finished.emit()

func onFinished():
	for c : GamepadSelectButton in $HBoxContainer.get_children():
		c.unfocus()
	$GamepadSelectCarousel.focus()
