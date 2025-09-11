extends AnimationStep

var targetMonigote : Monigote

@export var time : float = 3

@export var pointer : MeshInstance3D
@export var linePointer : MeshInstance3D

@onready var root = animationRoot()

func start():
	super()
	pointer.visible = true
	linePointer.visible = true
	$TargetingTimer.start(time)
	pickNewMonigote()
	await $TargetingTimer.timeout
	linePointer.freezeAnimation()
	var tween := create_tween().set_loops(3)
	tween.tween_callback(func (): pointer.visible = false)
	tween.tween_interval(.1)
	tween.tween_callback(func (): pointer.visible = true)
	tween.tween_interval(.1)
	end()

func _onActiveProcess(delta):
	linePointer.setSpeed((time - $TargetingTimer.time_left)*(time - $TargetingTimer.time_left))
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
	
	var newTime = randf_range(.5,1)
	#if (not $TargetingTimer.is_stopped()) and newTime + .2 > $TargetingTimer.time_left:
		#return
	
	targetMonigote = root.die.get_parent().getRandomMonigote()
	$SwitchTimer.start(newTime)
