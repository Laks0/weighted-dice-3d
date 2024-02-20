extends MeshInstance3D

signal reachedMiddle
signal dieDrop

func _ready():
	$AnimationPlayer.play("FromLeft")
	$AnimationPlayer.connect("animation_finished", queue_free)
