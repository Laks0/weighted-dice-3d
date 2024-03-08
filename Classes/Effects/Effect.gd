extends Node
class_name Effect

@export var effectName : String

var arena : Arena

## Solo para los efectos del 6
@export var duration : float = 15

func create(_arena : Arena) -> void:
	arena = _arena

func start() -> void:
	pass

func update(_delta : float) -> void:
	pass

func end() -> void:
	pass
