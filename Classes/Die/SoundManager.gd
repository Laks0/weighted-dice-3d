extends Node3D

## La magnitud mínima de la velocidad a la que se usa el sonido más fuerte.
## Todos los otros niveles se dividen equitativamente desde el 0 hasta ahí.
@export var maxVelocity : float = 3

@onready var die : Die = get_parent()

func onDieHit(_body):
	var n := get_child_count()
	var magnitude := die.linear_velocity.length()
	
	if magnitude >= maxVelocity:
		get_child(n-1).play()
		return
	
	var step : float = maxVelocity / n
	var intensity : int = floor(magnitude / step)
	get_child(intensity).play()
