extends Node3D

var currentBehaviour : DieBehaviourStep

func _ready():
	startRollAnimation()
	
	for child in get_children():
		if child is DieBehaviourStep:
			child.setDie(get_parent())
	
	for defaultBehaviour : DieBehaviourStep in $DefaultBehaviours.get_children():
		defaultBehaviour.finished.connect(startRollAnimation)
		defaultBehaviour.setDie(get_parent())

func startRandomDefaultBehaviour():
	var behaviour : DieBehaviourStep = $DefaultBehaviours.get_children().pick_random()
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

func _startBehaviour(behaviour : DieBehaviourStep):
	currentBehaviour = behaviour
	currentBehaviour.start()
