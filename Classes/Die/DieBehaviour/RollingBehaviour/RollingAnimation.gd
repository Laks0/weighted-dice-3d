extends AnimationStep

@onready var die : Die = get_parent().die
var result : int

func _onStart():
	die = get_parent().die

func animationFinished():
	finished.emit()
