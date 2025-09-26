extends Control

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
	for c : GamepadSelectButton in $EditButtons.get_children():
		c.controller = id
		c.unfocus()
	for c : GamepadSelectButton in $ControlButtons.get_children():
		c.controller = id
		c.unfocus()
	%BackButton.focus()
	controllerId = id
	
	_showSetBindings()

func finish():
	for c : GamepadSelectButton in $EditButtons.get_children():
		c.unfocus()
	for c : GamepadSelectButton in $ControlButtons.get_children():
		c.unfocus()
	%BackButton.focus()
	finished.emit()

func _showSetBindings():
	%GrabButtonTexture.setBindingOnControllersAction("grab", controllerId)
	%JumpButtonTexture.setBindingOnControllersAction("jump", controllerId)
	%PauseButtonTexture.setBindingOnControllersAction("pause", controllerId)

func _showTempBindings():
	%GrabButtonTexture.setBinding(_newEvents["grab"], controllerId)
	%JumpButtonTexture.setBinding(_newEvents["jump"], controllerId)
	%PauseButtonTexture.setBinding(_newEvents["pause"], controllerId)

func startEditting():
	for k in _newEvents.keys():
		_newEvents[k] = Controllers.getEventsForAction(k, controllerId)[0]
	
	%EditButton.visible = false
	%BackButton.visible = false
	%CancelButton.visible = true
	%AcceptButton.visible = true
	
	%CancelButton.focus()
	%EditButton.unfocus()
	
	for c in $EditButtons.get_children():
		c.disabled = false

func stopEditting():
	%EditButton.visible = true
	%BackButton.visible = true
	%CancelButton.visible = false
	%AcceptButton.visible = false
	
	%EditButton.focus()
	
	for c in $EditButtons.get_children():
		c.disabled = true

func acceptChanges():
	%AcceptButton.unfocus()
	for a in _newEvents.keys():
		Controllers.editEvent(a, controllerId, _newEvents[a])
	stopEditting()

func cancelChanges():
	%CancelButton.unfocus()
	_showSetBindings()
	stopEditting()

var _waitingToEdit := false
var _selectedAction := ""

func _startedEditting(action : String):
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
	if not _waitingToEdit:
		return
	
	if event.is_released():
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
