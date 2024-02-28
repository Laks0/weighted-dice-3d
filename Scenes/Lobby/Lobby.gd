extends Node3D

signal startBetting

@export var lobbyOutAnimationPlayer : AnimationPlayer
@export var chipHolder : ChipHolder

func _ready():
	$Maletin/AnimationPlayer.play("MaletinAAction_001")
	
	var monigotes := PlayerHandler.instantiatePlayers()
	
	var xPos = -3
	for m : Monigote in monigotes:
		m.position = Vector3(xPos, Globals.SPRITE_HEIGHT, -3)
		xPos += 1
		add_child(m)
	
	await get_tree().create_timer(10).timeout
	chipHolder.ownMonigotes(monigotes)
	await get_tree().create_timer(1).timeout
	
	lobbyOutAnimationPlayer.play("LobbyOutAnimation")
	$Maletin/AnimationPlayer.play_backwards("MaletinAAction_001")
