@tool
extends MultiStageMenu

signal finished

@onready var controllerId : int = Controllers.KB
# Necesito tener una porque solo permito controles para los que haya textura
@export var inputDisplayTexture : TextureRect

var _newEvents : Dictionary[String, InputEvent] = {
	"grab" : null,
	"jump" : null,
	"pause" : null
}

func setControllerId(id : int):
	controllerId = id
	
	_showSetBindings()

func finish():
	finished.emit()

func _showSetBindings():
	%GrabButtonTexture.setBindingOnControllersAction("grab", controllerId)
	%JumpButtonTexture.setBindingOnControllersAction("jump", controllerId)
	%PauseButtonTexture.setBindingOnControllersAction("pause", controllerId)

func _showTempBindings():
	%GrabButtonTexture.setBinding(_newEvents["grab"], controllerId)
	%JumpButtonTexture.setBinding(_newEvents["jump"], controllerId)
	%PauseButtonTexture.setBinding(_newEvents["pause"], controllerId)

func acceptChanges():
	for a in _newEvents.keys():
		Controllers.editEvent(a, controllerId, _newEvents[a])
	await get_tree().physics_frame
	finished.emit()

func cancelChanges():
	_showSetBindings()
	finished.emit()

var _waitingToEdit := false
var _selectedAction := ""

func _startedEditting(action : String):
	for k in _newEvents.keys():
		_newEvents[k] = Controllers.getEventsForAction(k, controllerId)[0]
	
	_selectedAction = action
	_waitingToEdit = true
	
	_showTempBindings()
	
	$ControlButtons.visible = false
	for c in $EditButtons.get_children():
		c.unfocus()
		c.disable()
		if not c.name.containsn(action):
			c.modulate.a = 0

func _input(event: InputEvent) -> void:
	if event.is_released():
		return
	
	# LT y RT son movimientos de ejes, pero registran muchas veces entonces hay que
	# darles un cooldown
	if event is InputEventJoypadMotion and inputDisplayTexture.isValidBinding(event):
		if $TriggerCooldown.is_stopped():
			$TriggerCooldown.start()
		else:
			return
	
	if $Warning.visible:
		if event.is_match(_newEvents["grab"]):
			acceptChanges()
		if event.is_match(_newEvents["jump"]):
			cancelChanges()
		return
	
	if not _waitingToEdit:
		return
	
	if not inputDisplayTexture.isValidBinding(event):
		return
	
	if event is InputEventKey:
		var otherKeyboard = Controllers.KB if controllerId == Controllers.KB2 else Controllers.KB2
		if Controllers.controllerHasEvent(otherKeyboard, event):
			return
	elif event.device != controllerId:
		return
	
	if Controllers.actionHasEvent("up", controllerId, event) or\
		Controllers.actionHasEvent("down", controllerId, event) or\
		Controllers.actionHasEvent("right", controllerId, event) or\
		Controllers.actionHasEvent("left", controllerId, event):
			return
	
	_changeEvent(event)

func _changeEvent(newEvent : InputEvent):
	for action in _newEvents.keys():
		if _newEvents[action] != null and _newEvents[action].is_match(newEvent, false):
			_newEvents[action] = null
			%AcceptButton.disable()
	
	_newEvents[_selectedAction] = newEvent
	
	if _newEvents.values().all(func (e): return e != null):
		%AcceptButton.enable()
	
	_showTempBindings()
	_waitingToEdit = false
	$ControlButtons.visible = true
	
	for c in $EditButtons.get_children():
		c.enable()
		c.modulate.a = 1
		if c.name.containsn(_selectedAction):
			get_tree().create_timer(.01).timeout.connect(c.focus)

func _onAcceptButtonPressed() -> void:
	if not Controllers.isKeyboard(controllerId):
		acceptChanges()
	else:
		await get_tree().physics_frame
		await get_tree().physics_frame
		_transitionTo(StringName("warning"))
