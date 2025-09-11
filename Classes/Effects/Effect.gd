extends Node
class_name Effect

# Por defecto los comportamientos del dado ignoran esta señal. El comportamiento
# de NO_DICE espera a esta señal para terminar
signal effectFinished

@export var effectName : String
@export var cardTexture : Texture

enum DieBehaviourType {RANDOM_DEFAULT, NO_DICE, CUSTOM}
@export var dieBehaviour : DieBehaviourType = DieBehaviourType.RANDOM_DEFAULT
var customDieBehaviour : PackedScene

var arena : Arena

func create(_arena : Arena) -> void:
	arena = _arena

func start() -> void:
	pass

func update(_delta : float) -> void:
	pass

func end() -> void:
	pass
