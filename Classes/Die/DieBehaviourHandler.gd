extends Node3D

@export var defaultBehaviour : Array[PackedScene]

var currentBehaviour : DieBehaviour

func _ready():
	startRandomDefaultBehaviour()

func startRandomDefaultBehaviour():
	var scene : PackedScene = defaultBehaviour.pick_random()
	currentBehaviour = scene.instantiate()
	currentBehaviour.start(get_parent())
	currentBehaviour.finished.connect(startRollAnimation)
	add_child(currentBehaviour)

func startRollAnimation():
	pass
