extends DieBehaviourStep

@export var time : float = .2

## La distancia *al cuadrado* mínima que tiene que tener la nueva posición elegida
@export var minSquaredDistanceToNewPosition : float = 1

var arena : Arena
var targetPosition : Vector3

func _onStart():
	arena = die.get_parent()
	targetPosition = die.position
	while targetPosition.distance_squared_to(die.position) <= minSquaredDistanceToNewPosition:
		targetPosition = arena.getRandomPosition(1.5, die.position.y)
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(die, "position", targetPosition, time)
	tween.tween_callback(end)
