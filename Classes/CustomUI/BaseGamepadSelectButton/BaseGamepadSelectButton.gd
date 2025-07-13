@tool
extends GamepadSelectUI
class_name BaseGamepadSelectButton

signal pressed

func _game_and_editor_process(_delta):
	if !focused:
		onNormalUpdate(_delta)
	
	if disabled:
		modulate.a = .5
	else:
		modulate.a = 1
	
	if !focused or !is_visible_in_tree():
		return
	
	if %OnclickedTime.is_stopped():
		onFocusedUpdate(_delta)
	else:
		onPressedTimeUpdate(_delta)

func _in_game_process(_delta):
	if !focused or !is_visible_in_tree():
		return

	if Input.is_action_just_pressed(actions["grab"]):
		pressed.emit()
		%OnclickedTime.start()

func onNormalUpdate(_delta):
	pass

func onFocusedUpdate(_delta):
	pass

func onPressedTimeUpdate(_delta):
	pass

func setLabelColor(color : Color):
	%Label.add_theme_color_override("font_color", color)
