@tool
extends BaseGamepadSelectButton
class_name GamepadSelectButton

@export var text : String

@export_group("Textures")
@export var normalTexture  : StyleBox
@export var focusedTexture : StyleBox
@export var pressedTexture : StyleBox

@export_group("Icon")
@export var movableIconNormalTexture  : Texture
@export var movableIconFocusedTexture : Texture
@export var movableIconPressedTexture : Texture
@export var movableIconUnderTexture : Texture
@export var movableIconPosition := Vector2.ZERO
@export var movableIconScale := Vector2.ONE

func _game_and_editor_process(_delta):
	super(_delta)
	%Label.text = text
	
	if movableIconUnderTexture != null:
		%MovableIconUnderTexture.texture = movableIconUnderTexture
	
	%MovableIcon.position = movableIconPosition
	%MovableIcon.scale = movableIconScale

func _updateTexture(backgroundTexture : StyleBox, iconTexture : Texture):
	add_theme_stylebox_override("panel", backgroundTexture)
	%MovableIcon.texture = iconTexture

func onNormalUpdate(_delta):
	_updateTexture(normalTexture, movableIconNormalTexture)

func onFocusedUpdate(_delta):
	_updateTexture(focusedTexture, movableIconFocusedTexture)

func onPressedTimeUpdate(_delta):
	_updateTexture(focusedTexture, movableIconFocusedTexture)
