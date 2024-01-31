extends Control

@export var startScene : PackedScene

func _on_start_button_pressed():
	get_tree().change_scene_to_packed(startScene)
