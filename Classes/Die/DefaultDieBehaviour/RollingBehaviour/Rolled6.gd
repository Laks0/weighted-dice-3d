extends AnimationStep

@onready var die : Die = animationRoot().die

func start():
	die = animationRoot().die
	die.freeze = true
	var outTween := get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	outTween.tween_property(die, "scale", Vector3.ZERO, .4)
	outTween.tween_callback(func(): 
		die.position = Vector3(-10, 3, 0)
		die.scale = Vector3.ONE)
	
	var effect : Effect = die.get_parent().effects[5]
	get_tree().create_timer(effect.duration).timeout.connect(end)
	super()

func end():
	die.freeze = false
	die.get_parent().environment.lightsOn()
	super()
