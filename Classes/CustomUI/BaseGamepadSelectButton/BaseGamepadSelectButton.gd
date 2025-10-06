@tool
extends GamepadSelectUI
class_name BaseGamepadSelectButton

signal pressed

@export var pressTime := .4
@onready var clickedTimer := Timer.new()

@export var greyOnDisabled := true

func _ready():
	super()
	clickedTimer.one_shot = true
	add_child(clickedTimer)

func _game_and_editor_process(_delta):
	if !focused:
		onNormalUpdate(_delta)
	
	if disabled:
		onDisabledUpdate(_delta)
	
	if !focused or !is_visible_in_tree():
		return
	
	if !disabled:
		if clickedTimer.is_stopped():
			onFocusedUpdate(_delta)
		else:
			onPressedTimeUpdate(_delta)

func _in_game_process(_delta):
	if !focused or !is_visible_in_tree():
		return

	if Input.is_action_just_pressed(actions["ui_ok"]):
		pressed.emit()
		clickedTimer.start(pressTime)

func onNormalUpdate(_delta):
	pass

func onFocusedUpdate(_delta):
	pass

func onPressedTimeUpdate(_delta):
	pass

func onDisabledUpdate(_delta):
	pass

func setLabelColor(color : Color):
	%Label.add_theme_color_override("font_color", color)

func disable():
	if greyOnDisabled:
		modulate.a = .5
	super()

func enable():
	modulate.a = 1
	super()
