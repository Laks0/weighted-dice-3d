extends Button
class_name GamepadSelectButton

signal movedUp
signal movedDown
signal movedLeft
signal movedRight

@export var controller : int # Un enum de Controllers
@export var focused := false

@export var upSelect    : GamepadSelectButton
@export var downSelect  : GamepadSelectButton
@export var leftSelect  : GamepadSelectButton
@export var rightSelect : GamepadSelectButton

var canMoveFocus := true

func _process(_delta):
	if controller == Controllers.KB or controller == Controllers.KB2:
		# Lo transforma en un botón normal
		mouse_filter = Control.MOUSE_FILTER_STOP
		return
	
	$FocusedOutline.visible = focused
	
	if !focused or !visible:
		return
	
	var actions : Dictionary = Controllers.getActions(controller)
	
	if Input.is_action_just_pressed(actions["grab"]):
		pressed.emit()
	
	if not canMoveFocus:
		return
	if Input.is_action_just_pressed(actions["left"]):
		movedLeft.emit()
		if is_instance_valid(leftSelect):
			changeFocus(leftSelect)
	elif Input.is_action_just_pressed(actions["right"]):
		movedRight.emit()
		if is_instance_valid(rightSelect):
			changeFocus(rightSelect)
	elif Input.is_action_just_pressed(actions["down"]):
		movedDown.emit()
		if is_instance_valid(downSelect):
			changeFocus(downSelect)
	elif Input.is_action_just_pressed(actions["up"]):
		movedUp.emit()
		if is_instance_valid(upSelect):
			changeFocus(upSelect)

func unfocus():
	focused = false

func focus():
	await get_tree().process_frame
	focused = true

func changeFocus(newFocus : GamepadSelectButton):
	unfocus()
	newFocus.focus()
