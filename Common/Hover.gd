extends Node3D

@export var yDisplacement : float = 1
@export var frequency : float = 1

func _ready():
	await get_tree().create_timer(randf_range(.01,.03)).timeout
	var tween := create_tween().set_loops()\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", position.y + yDisplacement, frequency/2)
	tween.tween_property(self, "position:y", position.y - yDisplacement, frequency/2)
