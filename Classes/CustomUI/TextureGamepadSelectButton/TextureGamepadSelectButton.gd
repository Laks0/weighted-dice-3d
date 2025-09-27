@tool
extends BaseGamepadSelectButton
class_name TextureGamepadSelectButton

@export var text : String

@export_group("Textures")
@export var normalTexture  : Texture
@export var focusedTexture : Texture
@export var pressedTexture : Texture

@export_group("Shadow")
@export var showShadow := true
@export_range(0, 1) var shadowStrength := .5
@export var shadowOffset := Vector2.ONE * 2


func _game_and_editor_process(_delta):
	super(_delta)
	$Label.text = text
	if showShadow:
		%ShadowRect.texture = $TextureRect.texture
		%ShadowRect.modulate.a = shadowStrength
		%ShadowRect.position = shadowOffset

func onNormalUpdate(_delta):
	$TextureRect.texture = normalTexture

func onFocusedUpdate(_delta):
	$TextureRect.texture = focusedTexture

func onPressedTimeUpdate(_delta):
	$TextureRect.texture = pressedTexture

func changeFocus(newFocus : GamepadSelectUI, dir : int):
	if newFocus.get_parent().get_parent() is VirtualKeyboard:
		SfxHandler.playSound("keyboardScroll")
	super.changeFocus(newFocus, dir)
