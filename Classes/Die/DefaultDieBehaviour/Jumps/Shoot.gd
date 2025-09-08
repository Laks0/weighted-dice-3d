extends AnimationStep

@export var pointer : MeshInstance3D
@export var linePointer : MeshInstance3D

@onready var root := animationRoot()

func start():
	super()
	
	var die : Die = root.die
	var targetPosition : Vector3 = root.targetPosition
	
	var targetTweenPosition : Vector3 = targetPosition #lerp(die.global_position, targetPosition,.7)
	
	var positionTween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	positionTween.tween_property(die, "global_position", 
		targetTweenPosition, .5)
	
	await positionTween.finished
	die.freeze = false
	die.throw(die.global_position.direction_to(targetPosition) * 10)
	pointer.visible = false
	linePointer.visible = false
	get_viewport().get_camera_3d().startShake(.2,.1)
	end()

func _onActiveProcess(_delta):
	linePointer.point(root.die.global_position, root.targetPosition)
