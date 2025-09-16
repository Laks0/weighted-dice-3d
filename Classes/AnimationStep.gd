extends Node3D
class_name AnimationStep

signal finished

@export var waitTimeBeforeEnd : float = 0.0

var active := false

func start():
	if active:
		return
	active = true
	_onStart()
	_startChildAnimationIfExists()

func _onStart():
	pass

func breakAnimation():
	await _endStep()
	get_parent().animationFinished()

func end():
	if not active:
		return
	await _endStep()
	if not _isThereNextStep():
		if not get_parent() is AnimationStep:
			return
		get_parent().animationFinished()
	else:
		_getNextStep().start()

func _endStep():
	active = false
	await get_tree().create_timer(waitTimeBeforeEnd).timeout
	_onEnd()
	finished.emit()

func _onEnd():
	pass

func _isThereNextStep() -> bool:
	if not get_parent() is AnimationStep:
		return false
	
	for i in range(get_index()+1, get_parent().get_child_count()):
		var c = get_parent().get_child(i)
		if c is AnimationStep:
			return true
	return false

func _getNextStep() -> AnimationStep:
	for i in range(get_index()+1, get_parent().get_child_count()):
		if get_parent().get_child(i) is AnimationStep:
			return get_parent().get_child(i)
	return null

func _startChildAnimationIfExists():
	for c in get_children():
		if c is AnimationStep:
			c.start()
			return

func _onActiveProcess(_delta):
	pass

func _process(delta):
	if active:
		_onActiveProcess(delta)

func animationFinished():
	end()

func animationRoot() -> AnimationStep:
	var v : AnimationStep = self
	var parent : Node = self
	while parent is AnimationStep:
		v = parent
		parent = v.get_parent()
	return v
