extends Node3D
class_name DieBehaviour

signal finished

var die : Die

var running := false

func start(parentDie : Die):
	if running:
		return
	die = parentDie
	running = true
	_onStart()

func _onStart():
	pass

func stop():
	if not running:
		return
	running = false
	_onStop()
	finished.emit()

func _onStop():
	pass

func _onCurrentEffectFinished():
	pass
