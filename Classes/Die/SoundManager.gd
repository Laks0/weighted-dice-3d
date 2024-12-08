extends Node3D

## La magnitud mínima de la velocidad a la que se usa el sonido más fuerte.
## Todos los otros niveles se dividen equitativamente desde el 0 hasta ahí.
@export var maxVelocity : float = 3
@onready var die : Die = get_parent()

func _ready():
	$Roll.play()
	rollSound()

func onDieHit(_body):
	var magnitude := die.linear_velocity.length() #en este momento magnitude va más o menos entre 0 y 8. Vamos a dividir en 8 para tener una suerte de normalización aproximada
	$Hit.volume_db = -14 + 14*magnitude/8
	$Hit.play()
	$Roll.play(randf_range(0, 4))

func _process(delta: float) -> void:
	rollSound()

func rollSound():
	var magnitude := die.linear_velocity.length()
	if get_parent().position.y >= 0 && get_parent().position.y < 2 && magnitude > 0.5:
		$Roll.volume_db = -18 + 6*(position.y*6/2 + magnitude/2)
	else:
		$Roll.volume_db = -90
