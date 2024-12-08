extends Node3D

func _process(_delta):
	$R.position = $L.position
	$R.position.x *= -1

func go_to_ready_position(time : float) -> void:
	visible = true
	var tween := create_tween()
	tween.tween_property($L, "position", $ReadyL.position, time)

func go_to_rest(time : float) -> void:
	var tween := create_tween()
	tween.tween_property($L, "position", $RestL.position, time)
	await tween.finished
	visible = false
