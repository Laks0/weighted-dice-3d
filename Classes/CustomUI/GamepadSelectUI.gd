@tool
extends Control
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

@export_group("Neighbours")

## Automáticamente cada frame se fija si está en un hbox o un vbox y setea sus
## vecinos dependiendo de los nodos en su nivel del árbol
@export var autoSetNeighbours := true

@export_tool_button("Set automatic neighbours") var automaticButton = setAutomaticNeighbours
@export_tool_button("Reset neighbours") var resetButton = resetNeighbours

@export var upSelect    : GamepadSelectUI
@export var downSelect  : GamepadSelectUI
@export var leftSelect  : GamepadSelectUI
@export var rightSelect : GamepadSelectUI

@export var upFallback    : GamepadSelectUI
@export var downFallback  : GamepadSelectUI
@export var leftFallback  : GamepadSelectUI
@export var rightFallback : GamepadSelectUI


enum {UP, DOWN, LEFT, RIGHT, NONE}

var actions : Dictionary

func _ready():
	if focused:
		focus(LEFT)

func _process(delta):
	_game_and_editor_process(delta)
	
	if autoSetNeighbours:
		setAutomaticNeighbours()
	
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

func _get_current_movement() -> int:
	if Input.is_action_just_pressed(actions["left"]):
		return LEFT
	elif Input.is_action_just_pressed(actions["right"]):
		return RIGHT
	elif Input.is_action_just_pressed(actions["down"]):
		return DOWN
	elif Input.is_action_just_pressed(actions["up"]):
		return UP
	return NONE

func _handle_movement():
	var movement := _get_current_movement()
	if movement == LEFT:
		movedLeft.emit()
		if is_instance_valid(leftSelect):
			changeFocus(leftSelect, LEFT)
	elif movement == RIGHT:
		movedRight.emit()
		if is_instance_valid(rightSelect):
			changeFocus(rightSelect, RIGHT)
	elif movement == DOWN:
		movedDown.emit()
		if is_instance_valid(downSelect):
			changeFocus(downSelect, DOWN)
	elif movement == UP:
		movedUp.emit()
		if is_instance_valid(upSelect):
			changeFocus(upSelect, UP)

func changeFocus(newFocus : GamepadSelectUI, dir : int):
	SfxHandler.playSound("focus")
	unfocus()
	newFocus.focus(dir)

func unfocus():
	if focused:
		endedFocus.emit()
	focused = false

func focus(dir : int = LEFT):
	var newFocus
	if disabled or not visible:
		if dir == LEFT:
			newFocus = leftFallback
		elif dir == RIGHT:
			newFocus = rightFallback
		elif dir == UP:
			newFocus = upFallback
		elif dir == DOWN:
			newFocus = downFallback
		
		if is_instance_valid(newFocus):
			changeFocus(newFocus, dir)
		return
	await get_tree().process_frame
	focused = true
	startedFocus.emit()

func disable():
	disabled = true
	if not focused:
		return
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

func resetNeighbours():
	var directionsPrefix := ["right", "down", "up", "left"]
	for prefix in directionsPrefix:
		set(prefix + "Select", null)
		set(prefix + "Fallback", null)

## Establece los vecinos del botón automáticamente teniendo en cuenta el orden de
## los hijos del container al que pertenece (solo funciona cuando el nodo está en
## un hbox o vbox)
func setAutomaticNeighbours():
	var increasingNeighbourDirectionPrefix : String
	var decreasingNeighbourDirectionPrefix : String
	if get_parent() is HBoxContainer:
		increasingNeighbourDirectionPrefix = "right"
		decreasingNeighbourDirectionPrefix = "left"
	elif get_parent() is VBoxContainer:
		increasingNeighbourDirectionPrefix = "down"
		decreasingNeighbourDirectionPrefix = "up"
	else:
		return
	
	var index := get_index()
	var nextIndex := -1
	var prevIndex := 10000
	var firstIndex := -1
	var lastIndex := -1
	var container := get_parent()
	for i in range(container.get_child_count()):
		var child = container.get_child(i)
		if not child is BaseGamepadSelectButton:
			continue
		if not child.visible:
			continue
		
		lastIndex = i
		if firstIndex == -1:
			firstIndex = i
		if i < index:
			prevIndex = i
		if i > index and nextIndex == -1:
			nextIndex = i
	
	# Para el wrap arround
	nextIndex = max(nextIndex, firstIndex)
	prevIndex = min(prevIndex, lastIndex)
	
	set(increasingNeighbourDirectionPrefix + "Select", container.get_child(nextIndex))
	set(increasingNeighbourDirectionPrefix + "Fallback", container.get_child(nextIndex))
	set(decreasingNeighbourDirectionPrefix + "Select", container.get_child(prevIndex))
	set(decreasingNeighbourDirectionPrefix + "Fallback", container.get_child(prevIndex))
