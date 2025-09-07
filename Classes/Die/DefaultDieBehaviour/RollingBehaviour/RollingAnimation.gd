extends AnimationStep

@onready var die : Die = get_parent().die
var result : int

func start():
	die = get_parent().die
	super()

func animationFinished():
	finished.emit()
