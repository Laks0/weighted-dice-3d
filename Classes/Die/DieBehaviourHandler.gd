extends Node3D

@export var defaultBehaviour : Array[PackedScene]

var currentBehaviour : DieBehaviour

func _ready():
	startRollAnimation()

func startRandomDefaultBehaviour():
	var scene : PackedScene = defaultBehaviour.pick_random()
	var behaviour : DieBehaviour = scene.instantiate()
	_startBehaviour(behaviour)
	add_child(behaviour)
	behaviour.finished.connect(startRollAnimation)

func startRollAnimation():
	_startBehaviour($RollingDieBehaviour)

func _onCurrentEffectFinished():
	currentBehaviour._onCurrentEffectFinished()

func _onEffectStarted(effect : Effect):
	if effect.dieBehaviour == Effect.DieBehaviourType.RANDOM_DEFAULT:
		startRandomDefaultBehaviour()
	elif effect.dieBehaviour == Effect.DieBehaviourType.NO_DICE:
		_startBehaviour($NoDiceBehaviour)
	elif effect.dieBehaviour == Effect.DieBehaviourType.CUSTOM:
		pass

func _startBehaviour(behaviour : DieBehaviour):
	currentBehaviour = behaviour
	currentBehaviour.start(get_parent())
