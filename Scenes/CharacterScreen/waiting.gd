extends Control

@export var mainKeyboardHint : Control
@export var mainKeyboardButtonDisplay : Control
@export var secondaryKeyboardHint : Control
@export var secondaryKeyboardButtonDisplay : Control
@export var controllerHint : Control
@export var xboxButtonDisplay : Control
@export var psButtonDisplay : Control

func _process(_delta: float) -> void:
	var waiting : Array[int] = get_parent().devicesWaiting
	
	mainKeyboardButtonDisplay.setBinding(
		Controllers.getEventsForAction("grab", Controllers.KB)[0], Controllers.KB
	)
	secondaryKeyboardButtonDisplay.setBinding(
		Controllers.getEventsForAction("grab", Controllers.KB2)[0], Controllers.KB2
	)
	mainKeyboardHint.visible = waiting.has(Controllers.KB)
	secondaryKeyboardHint.visible = waiting.has(Controllers.KB2)
	
	var hasXbox = false
	var hasPS = false
	for id in waiting:
		if Controllers.getControllerType(id) == Controllers.ControllerType.XBOX:
			hasXbox = true
			
			xboxButtonDisplay.setBinding(
				Controllers.getEventsForAction("grab", id)[0], id
			)
		elif Controllers.getControllerType(id) == Controllers.ControllerType.PS:
			hasPS = true
			
			psButtonDisplay.setBinding(
				Controllers.getEventsForAction("grab", id)[0], id
			)
	
	controllerHint.visible = hasXbox or hasPS
	xboxButtonDisplay.visible = hasXbox
	psButtonDisplay.visible = hasPS
