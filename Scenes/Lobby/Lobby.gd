extends Node3D

signal startBetting

@export var lobbyOutAnimationPlayer : AnimationPlayer

func _ready():
	$Maletin/AnimationPlayer.play("MaletinAAction_001")
	
	var monigotes := PlayerHandler.instantiatePlayers()
	
	var xPos = -3
	for m : Monigote in monigotes:
		m.position = Vector3(xPos, Globals.SPRITE_HEIGHT, -3)
		xPos += 1
		add_child(m)
	
	await get_tree().create_timer(2).timeout
	for m : Monigote in monigotes:
		m.queue_free()
	
	lobbyOutAnimationPlayer.play("LobbyOutAnimation")
	$Maletin/AnimationPlayer.play_backwards("MaletinAAction_001")
