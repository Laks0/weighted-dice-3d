extends Control

@export var mainKeyboardHint : Control
@export var mainKeyboardButtonDisplay : Control
@export var secondaryKeyboardHint : Control
@export var secondaryKeyboardButtonDisplay : Control
@export var controllerHint : Control
@export var xboxButtonDisplay : Control
@export var psButtonDisplay : Control

func _ready() -> void:
	_visibility[mainKeyboardHint] = true
	_updateElements()

func _process(_delta: float) -> void:
	_updateElements()

func _updateElements():
	var waiting : Array[int] = get_parent().devicesWaiting
	
	mainKeyboardButtonDisplay.setBindingOnControllersAction("ui_ok", Controllers.KB)
	secondaryKeyboardButtonDisplay.setBindingOnControllersAction("ui_ok", Controllers.KB2)
	mainKeyboardHint.visible = waiting.has(Controllers.KB)
	secondaryKeyboardHint.visible = waiting.has(Controllers.KB2)
	
	var hasXbox = false
	var hasPS = false
	for id in waiting:
		if Controllers.getControllerType(id) == Controllers.ControllerType.XBOX:
			hasXbox = true
			
			xboxButtonDisplay.setBindingOnControllersAction("ui_ok", id)
		elif Controllers.getControllerType(id) == Controllers.ControllerType.PS:
			hasPS = true
			
			psButtonDisplay.setBindingOnControllersAction("ui_ok", id)
	
	controllerHint.visible = hasXbox or hasPS
	xboxButtonDisplay.visible = hasXbox
	psButtonDisplay.visible = hasPS

var _visibility : Dictionary[Control, bool]
