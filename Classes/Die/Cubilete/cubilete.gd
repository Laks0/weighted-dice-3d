extends MeshInstance3D

@warning_ignore("unused_signal")
signal reachedMiddle
@warning_ignore("unused_signal")
signal dieDrop

func _ready():
	$AnimationPlayer.play("FromLeft")
	$AnimationPlayer.connect("animation_finished", func(_name): queue_free())
