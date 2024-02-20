@tool
extends State

@export var cubileteScene : PackedScene

## El tiempo que tarda el cubilete en llegar al centro
@export var timeForMiddle : float = .5
## El tiempo que dura la animación para ir al centro
@export var animationTime : float = .1

func _on_enter(_args):
	var positionTween := create_tween().set_ease(Tween.EASE_IN)
	
	# Pone el dado para ser agarrado por el cubilete y lo esconde cuando lo agarra
	positionTween.tween_interval(timeForMiddle - animationTime)
	positionTween.tween_property(target, "position", Vector3(0, 1, 0), animationTime)
	positionTween.connect("finished", func(): target.visible = false)
	
	var cubilete = cubileteScene.instantiate()
	get_parent().add_child(cubilete)
	
	cubilete.connect("dieDrop", func():
		target.position = cubilete.position
		target.visible = true
		change_to_next())
