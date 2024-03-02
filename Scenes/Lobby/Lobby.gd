extends Node3D

signal startBetting

@export var lobbyOutAnimationPlayer : AnimationPlayer
@export var chipHolder : ChipHolder
@export var maxLobbyTime := 50.0

func _ready():
	$Maletin/AnimationPlayer.play("MaletinAAction_001")
	
	var monigotes := PlayerHandler.instantiatePlayers()
	
	var xPos = -3
	for m : Monigote in monigotes:
		m.position = Vector3(xPos, Globals.SPRITE_HEIGHT, -3)
		xPos += 1
		add_child(m)
	
	get_tree().create_timer(maxLobbyTime).timeout.connect(func():
		if lobbyOutAnimationPlayer.is_playing():
			return
		
		for mon in monigotes:
			if mon.get_parent() != self:
				continue
			chipHolder.ownMonigote(mon)
		
		await get_tree().create_timer(1).timeout
		startExitAnimation()
	)

func _on_ready_area_body_entered(body):
	if not body is Monigote:
		return
	
	if not body.is_processing():
		return
	
	body.set_process(false)
	body.set_physics_process(false)
	
	await create_tween().tween_property(body, "position", $JumpPosition.position, .1).finished
	
	chipHolder.ownMonigote(body)
	
	if not get_children().any(func(child): return child is Monigote):
		startExitAnimation()

func startExitAnimation():
	lobbyOutAnimationPlayer.play("LobbyOutAnimation")
	$Maletin/AnimationPlayer.play_backwards("MaletinAAction_001")
