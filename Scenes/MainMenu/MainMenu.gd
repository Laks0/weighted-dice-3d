extends Control

@export var startScene : PackedScene
var dijoTimba := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	SoundtrackHandler.playTrack()
	
	var tween := create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($GameName, "position:y", -50, 2).as_relative()
	tween.tween_property($GameName, "position:y", 50, 2).as_relative()
	await get_tree().create_timer(1).timeout
	Narrator.get_node("VOX").volume_db = -5
	if !dijoTimba:
		Narrator.playBank("menu_titulo")
func _on_start_button_pressed():
	Narrator.get_node("VOX").volume_db = -3
	
	dijoTimba = true
	SfxHandler.playSound("buttonSelect")
	await get_tree().create_timer(0.3).timeout
	Narrator.playBank("menu_timba")
	await get_tree().create_timer(1.2).timeout
	
	
	get_tree().change_scene_to_packed(startScene)

var _leaving := false
func _input(event):
	if _leaving:
		return
	if event.is_action_pressed("limbo_console_toggle"):
		return
	elif event.is_pressed() and not event is InputEventMouse:
		var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		tween.tween_property($StartText, "position:x", -500, .5)
		_on_start_button_pressed()
		_leaving = true
