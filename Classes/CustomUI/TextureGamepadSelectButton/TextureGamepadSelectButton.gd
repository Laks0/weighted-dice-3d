@tool
extends BaseGamepadSelectButton
class_name TextureGamepadSelectButton

@export var text : String

@export_group("Textures")
@export var normalTexture  : Texture
@export var focusedTexture : Texture
@export var pressedTexture : Texture

func _game_and_editor_process(_delta):
	super(_delta)
	$Label.text = text

func onNormalUpdate(_delta):
	$TextureRect.texture = normalTexture

func onFocusedUpdate(_delta):
	$TextureRect.texture = focusedTexture

func onPressedTimeUpdate(_delta):
	$TextureRect.texture = pressedTexture
