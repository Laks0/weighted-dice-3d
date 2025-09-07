extends Node3D
class_name DieBehaviour

signal finished

var die : Die

func start(parentDie : Die):
	die = parentDie

func stop():
	finished.emit()
	queue_free()
