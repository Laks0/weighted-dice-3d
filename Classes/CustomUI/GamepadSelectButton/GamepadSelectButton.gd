@tool
extends GamepadSelectUI
class_name GamepadSelectButton

signal pressed

@export var text : String


@export_group("Texturas")
@export var normalTexture  : Texture
@export var focusedTexture : Texture
@export var pressedTexture : Texture
@export var underTexture : Texture

func _game_and_editor_process(_delta):
	%Label.text = text
	if !focused:
		%OverTexture.texture = normalTexture
	
	if disabled:
		modulate.a = .5
	else:
		modulate.a = 1
	
	if underTexture != null:
		%UnderTexture.texture = underTexture
	
	if !focused or !is_visible_in_tree():
		return
	
	if %OnclickedTime.is_stopped():
		%OverTexture.texture = focusedTexture
	else:
		%OverTexture.texture = pressedTexture

func _in_game_process(_delta):
	if !focused or !is_visible_in_tree():
		return

	if Input.is_action_just_pressed(actions["grab"]):
		pressed.emit()
		%OnclickedTime.start()

func setLabelColor(color : Color):
	%Label.label_settings.font_color = color
