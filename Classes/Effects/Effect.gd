extends Node
class_name Effect

enum Effects {
	CHIPS_ARE_DOWN,
	ALL_IN,
	OLIVE_ROLL,
	MIND_THE_GAP,
	SPIKES,
	FULL_HOUSE
}

@export var effectName : String
@export var effectId : Effects

var arena : Arena

func create(_arena : Arena) -> void:
	arena = _arena

func start() -> void:
	pass

func update(_delta : float) -> void:
	pass

func end() -> void:
	pass
