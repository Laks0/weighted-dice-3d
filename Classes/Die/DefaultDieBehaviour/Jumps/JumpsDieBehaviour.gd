extends DieBehaviour

func _ready():
	await get_tree().create_timer(.5).timeout
	stop()
