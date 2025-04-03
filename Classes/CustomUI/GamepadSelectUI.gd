@tool
extends Container
class_name GamepadSelectUI

signal startedFocus
signal endedFocus

signal movedUp
signal movedDown
signal movedLeft
signal movedRight

@export var controller : int = Controllers.KB # Un enum de Controllers

@export var focused  := false
@export var disabled := false

@export_group("Vecinos")
@export var upSelect    : GamepadSelectButton
@export var downSelect  : GamepadSelectButton
@export var leftSelect  : GamepadSelectButton
@export var rightSelect : GamepadSelectButton

@export var upFallback    : GamepadSelectButton
@export var downFallback  : GamepadSelectButton
@export var leftFallback  : GamepadSelectButton
@export var rightFallback : GamepadSelectButton

enum {UP, DOWN, LEFT, RIGHT}

var actions : Dictionary

func _ready():
	if focused:
		focus(LEFT)

func _process(delta):
	_game_and_editor_process(delta)
	if Engine.is_editor_hint():
		return
	actions = Controllers.getActions(controller)

	_in_game_process(delta)

	if focused and is_visible_in_tree():
		_handle_movement()

func _in_game_process(_delta):
	pass

func _game_and_editor_process(_dela):
	pass

func _handle_movement():
	if Input.is_action_just_pressed(actions["left"]):
		movedLeft.emit()
		if is_instance_valid(leftSelect):
			changeFocus(leftSelect, LEFT)
	elif Input.is_action_just_pressed(actions["right"]):
		movedRight.emit()
		if is_instance_valid(rightSelect):
			changeFocus(rightSelect, RIGHT)
	elif Input.is_action_just_pressed(actions["down"]):
		movedDown.emit()
		if is_instance_valid(downSelect):
			changeFocus(downSelect, DOWN)
	elif Input.is_action_just_pressed(actions["up"]):
		movedUp.emit()
		if is_instance_valid(upSelect):
			changeFocus(upSelect, UP)

func changeFocus(newFocus : GamepadSelectButton, dir : int):
	unfocus()
	newFocus.focus(dir)

func unfocus():
	focused = false
	endedFocus.emit()

func focus(dir : int = LEFT):
	if disabled:
		if dir == LEFT:
			changeFocus(leftFallback, LEFT)
		elif dir == RIGHT:
			changeFocus(rightFallback, RIGHT)
		elif dir == UP:
			changeFocus(upFallback, UP)
		elif dir == DOWN:
			changeFocus(downFallback, DOWN)
		return
	await get_tree().process_frame
	focused = true
	startedFocus.emit()

func disable():
	disabled = true
	if is_instance_valid(leftFallback):
		changeFocus(leftFallback, LEFT)
	elif is_instance_valid(rightFallback):
		changeFocus(rightFallback, RIGHT)
	elif is_instance_valid(downFallback):
		changeFocus(downFallback, DOWN)
	elif is_instance_valid(upFallback):
		changeFocus(upFallback, UP)

func enable():
	disabled = false
