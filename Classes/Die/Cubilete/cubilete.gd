extends MeshInstance3D

signal reachedMiddle
signal dieDrop

func _ready():
	$AnimationPlayer.play("FromLeft")
	$AnimationPlayer.connect("animation_finished", func(_name): queue_free())
