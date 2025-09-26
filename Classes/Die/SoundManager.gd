extends Node3D

## La magnitud mínima de la velocidad a la que se usa el sonido más fuerte.
## Todos los otros niveles se dividen equitativamente desde el 0 hasta ahí.
@export var maxVelocity : float = 3
@onready var die : Die = get_parent()

func _ready():
	$Roll.play()
	rollSound()

func onDieHit(body):
	var magnitude := die.linear_velocity.length() #en este momento magnitude va más o menos entre 0 y 8. Vamos a dividir en 8 para tener una suerte de normalización aproximada
	$Hit.volume_db = -17 + 14*magnitude/8
	$Hit.play()
	$Wall.volume_db = -13 + 9*magnitude/8
	$Felt.volume_db = -16 + 6*magnitude/8
	$Roll.play(randf_range(0, 4))
	if body.is_in_group("Table"):
		playFelt()
	if body.is_in_group("Walls"):
		playWall()

func _process(_delta: float) -> void:
	rollSound()

func rollSound():
	var magnitude := die.linear_velocity.length()
	if get_parent().position.y >= 0 && get_parent().position.y < 2 && magnitude > 0.5:
		$Roll.volume_db = -18 + 6*(position.y*6/2 + magnitude/2)
	else:
		$Roll.volume_db = -90

func playStomp():
	$Stomp.play()

func playChangeStomp():
	$ChangeStomp.play()

func playSplat():
	$Splat.play()
	
func playFelt():
	$Felt.play()

func playWall():
	$Wall.play()
