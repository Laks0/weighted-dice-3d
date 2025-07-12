@tool
extends GamepadSelectUI
class_name GamepadSelectButton

signal pressed

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
	%Label.text = text
	if !focused:
		_updateTexture(normalTexture, movableIconNormalTexture)
	
	if disabled:
		modulate.a = .5
	else:
		modulate.a = 1
	
	if movableIconUnderTexture != null:
		%MovableIconUnderTexture.texture = movableIconUnderTexture
	
	%MovableIcon.position = movableIconPosition
	%MovableIcon.scale = movableIconScale
	
	if !focused or !is_visible_in_tree():
		return
	
	if %OnclickedTime.is_stopped():
		_updateTexture(focusedTexture, movableIconFocusedTexture)
	else:
		_updateTexture(pressedTexture, movableIconPressedTexture)

func _in_game_process(_delta):
	if !focused or !is_visible_in_tree():
		return

	if Input.is_action_just_pressed(actions["grab"]):
		pressed.emit()
		%OnclickedTime.start()

func setLabelColor(color : Color):
	%Label.label_settings.font_color = color

func _updateTexture(backgroundTexture : StyleBox, iconTexture : Texture):
	add_theme_stylebox_override("panel", backgroundTexture)
	%MovableIcon.texture = iconTexture
