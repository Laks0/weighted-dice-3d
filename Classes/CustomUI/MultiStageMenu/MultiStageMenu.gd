@tool
extends Control
class_name MultiStageMenu

@export var stages : Dictionary[StringName, MenuStage]
@export var firstStage : StringName : set = _setFirstStage

var _currentStage : StringName

func restart() -> void:
	_transitionTo(firstStage)

func _ready() -> void:
	for s : MenuStage in stages.values():
		s.requestTransition.connect(_transitionTo)
	restart()

func _transitionTo(newStage : StringName) -> void:
	if stages.is_empty():
		return
	if stages.has(_currentStage):
		stages[_currentStage].end()
	_currentStage = newStage
	if stages.has(newStage):
		stages[_currentStage].start(self)
	else:
		_transitionTo(stages.keys()[0])

func _setFirstStage(newVal : StringName):
	if not Engine.is_editor_hint():
		return
	firstStage = newVal
	_transitionTo(firstStage)
