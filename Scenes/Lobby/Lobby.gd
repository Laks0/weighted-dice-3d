extends Node3D

signal startBetting

func _ready():
	var monigotes := PlayerHandler.instantiatePlayers()
	
	var xPos = -3
	for m : Monigote in monigotes:
		m.position = Vector3(xPos, Globals.SPRITE_HEIGHT, -3)
		xPos += 1
		add_child(m)
	
	await get_tree().create_timer(15).timeout
	startBetting.emit()
	for m : Monigote in monigotes:
		m.queue_free()
