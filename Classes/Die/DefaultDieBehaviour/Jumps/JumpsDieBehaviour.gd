extends DieBehaviour

func _ready():
	$JumpsAnimation.start()

func _onStop():
	queue_free()
