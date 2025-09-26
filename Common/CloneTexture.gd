@tool

extends TextureRect

@export var toClone : Control

func _process(_delta: float) -> void:
	texture = toClone.texture
