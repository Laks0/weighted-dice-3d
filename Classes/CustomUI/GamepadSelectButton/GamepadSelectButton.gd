@tool
extends TextureRect
class_name GamepadSelectButton

signal movedUp
signal movedDown
signal movedLeft
signal movedRight
signal pressed
signal startedFocus
signal endedFocus

@export var controller : int # Un enum de Controllers
@export var focused  := false
@export var disabled := false

## Automáticamente cada frame se fija si está en un hbox o un vbox y setea sus
## vecinos dependiendo de los nodos en su nivel del árbol
@export var autoSetNeighbours := true
@export_tool_button("Set automatic neighbours") var automaticButton = setAutomaticNeighbours
@export_tool_button("Reset neighbours") var resetButton = resetNeighbours

@export var upSelect    : GamepadSelectButton
@export var downSelect  : GamepadSelectButton
@export var leftSelect  : GamepadSelectButton
@export var rightSelect : GamepadSelectButton

@export var upFallback    : GamepadSelectButton
@export var downFallback  : GamepadSelectButton
@export var leftFallback  : GamepadSelectButton
@export var rightFallback : GamepadSelectButton

@export var normalTexture  : Texture
@export var focusedTexture : Texture
@export var pressedTexture : Texture

@export var underTexture : Texture

var canMoveFocus := true

@export var text : String

enum {UP, DOWN, LEFT, RIGHT}

func _ready():
	if focused:
		focus(LEFT)

func _process(_delta):
	$Label.text = text
	if !focused:
		texture = normalTexture
	
	if disabled:
		modulate.a = .5
	else:
		modulate.a = 1
	
	if underTexture != null:
		$UnderTexture.texture = underTexture
	
	if autoSetNeighbours:
		setAutomaticNeighbours()
	
	if !focused or !is_visible_in_tree():
		return
	
	if $OnclickedTime.is_stopped():
		texture = focusedTexture
	else:
		texture = pressedTexture
	
	# No seguir procesando si no está en el juego (para el @tool)
	if Engine.is_editor_hint():
		return
	
	var actions : Dictionary = Controllers.getActions(controller)
	
	if Input.is_action_just_pressed(actions["grab"]):
		pressed.emit()
		$OnclickedTime.start()
	
	if not canMoveFocus:
		return
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

func changeFocus(newFocus : GamepadSelectButton, dir : int):
	unfocus()
	newFocus.focus(dir)

func disableButton():
	disabled = true
	if is_instance_valid(leftFallback):
		changeFocus(leftFallback, LEFT)
	elif is_instance_valid(rightFallback):
		changeFocus(rightFallback, RIGHT)
	elif is_instance_valid(downFallback):
		changeFocus(downFallback, DOWN)
	elif is_instance_valid(upFallback):
		changeFocus(upFallback, UP)

func enableButton():
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
	var prevIndex := 1e10
	var firstIndex := -1
	var lastIndex := -1
	var container := get_parent()
	for i in range(container.get_child_count()):
		var child = container.get_child(i)
		if not child is GamepadSelectButton:
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
