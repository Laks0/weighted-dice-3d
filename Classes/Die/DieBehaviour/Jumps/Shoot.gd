extends AnimationStep

@export var pointer : MeshInstance3D
@export var linePointer : MeshInstance3D

@onready var root : AnimationStep = animationRoot()

@export var finalDiceImpulseForce : float = 100

var die : Die

func _ready():
	finished.connect(func (): die.hitting = false)

func start():
	super()
	
	die = root.die
	die.hitting = true
	
	var targetPosition : Vector3 = root.targetPosition
	
	var targetTweenPosition : Vector3 = lerp(die.global_position, targetPosition,.9)
	
	var positionTween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	positionTween.tween_property(die, "global_position", 
		targetTweenPosition, .5)
	
	await positionTween.finished
	die.freeze = false
	die.throw(die.global_position.direction_to(targetPosition) * finalDiceImpulseForce)
	pointer.visible = false
	linePointer.visible = false
	get_viewport().get_camera_3d().startShake(.2,.1)
	die.get_node("SoundManager").playStomp()
	end()

func _onActiveProcess(_delta):
	linePointer.point(root.die.global_position, root.targetPosition)
