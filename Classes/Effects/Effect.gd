extends Node
class_name Effect

@export var effectName : String

var arena : Arena

func create(_arena : Arena) -> void:
	arena = _arena

func start() -> void:
	pass

func update(_delta : float) -> void:
	pass

func end() -> void:
	pass
