extends AnimationStep

var targetMonigote : Monigote

@export var time : float = 3

@export var pointer : MeshInstance3D
@export var linePointer : MeshInstance3D

@onready var root = animationRoot()

func start():
	super()
	pickNewMonigote()
	pointer.visible = true
	linePointer.visible = true
	await get_tree().create_timer(time).timeout
	end()

func _onActiveProcess(delta):
	if not is_instance_valid(targetMonigote):
		return
	var newTargetPosition := targetMonigote.global_position
	newTargetPosition.y=0
	root.targetPosition = lerp(
		root.targetPosition, newTargetPosition, 10*delta)
	
	root.die.look_at(root.targetPosition)
	pointer.global_position = root.targetPosition
	linePointer.point(root.die.global_position, root.targetPosition)

func pickNewMonigote():
	if not active:
		return
	targetMonigote = root.die.get_parent().getRandomMonigote()
	$SwitchTimer.start(randf_range(.5, 1))
