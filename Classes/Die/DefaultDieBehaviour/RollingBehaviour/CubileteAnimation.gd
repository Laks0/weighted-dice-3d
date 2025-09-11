extends AnimationStep

@export var cubileteScene : PackedScene

## El tiempo que tarda el cubilete en llegar al centro
@export var timeForMiddle : float = .5
## El tiempo que dura la animación para ir al centro
@export var animationTime : float = .1

@onready var die : Die = animationRoot().die

func _onStart():
	die = animationRoot().die
	# Espera a que empiece la animación para desabilitar las colisiones
	get_tree().create_timer(timeForMiddle - animationTime)\
		.connect("timeout", die.disableCollision)
	
	var positionTween := create_tween().set_ease(Tween.EASE_IN)
	
	# Pone el dado para ser agarrado por el cubilete y lo esconde cuando lo agarra
	positionTween.tween_interval(timeForMiddle - animationTime)
	positionTween.tween_property(die, "position", Vector3(0, 1, 0), animationTime)
	positionTween.parallel().tween_callback(die.emit_signal.bind("onCubilete"))
	
	positionTween.connect("finished", func(): die.visible = false)
	
	var cubilete = cubileteScene.instantiate()
	cubilete.position = Vector3(-10,0,0)
	die.get_parent().add_child(cubilete)
	
	cubilete.connect("dieDrop", func():
		die.position = cubilete.position + Vector3.DOWN
		die.visible = true
		die.enableCollision()
		die.emit_signal("dropped")
		end())
