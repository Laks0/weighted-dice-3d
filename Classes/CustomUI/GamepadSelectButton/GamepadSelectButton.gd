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
@export var focused := false

@export var upSelect    : GamepadSelectButton
@export var downSelect  : GamepadSelectButton
@export var leftSelect  : GamepadSelectButton
@export var rightSelect : GamepadSelectButton

@export var normalTexture  : Texture
@export var focusedTexture : Texture
@export var pressedTexture : Texture

@export var underTexture : Texture

var canMoveFocus := true

@export var text : String

func _ready():
	if focused:
		focus()

func _process(_delta):
	$Label.text = text
	if !focused:
		texture = normalTexture
	
	if underTexture != null:
		$UnderTexture.texture = underTexture
	
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
	endedFocus.emit()

func focus():
	await get_tree().process_frame
	focused = true
	startedFocus.emit()

func changeFocus(newFocus : GamepadSelectButton):
	unfocus()
	newFocus.focus()
