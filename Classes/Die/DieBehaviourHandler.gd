extends Node3D

var currentBehaviour : DieBehaviour

func _ready():
	startRollAnimation()
	
	for behaviour : DieBehaviour in $DefaultBehaviours.get_children():
		behaviour.finished.connect(startRollAnimation)

func startRandomDefaultBehaviour():
	var behaviour : DieBehaviour = $DefaultBehaviours.get_children().pick_random()
	_startBehaviour(behaviour)

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
