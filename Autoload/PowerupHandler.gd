extends Node

@onready var powerUpPool = [
#	preload("res://Clases/Powerups/ExtraLifePowerup.tscn"),
#	preload("res://Clases/Powerups/StunGunPowerup.tscn"),
#	preload("res://Clases/Powerups/UngrabbablePowerup.tscn"),
	]

func getRandomPowerUp() -> Resource:
	return powerUpPool[randi() % len(powerUpPool)]
