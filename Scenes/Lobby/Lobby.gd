extends Node3D

signal startBetting

@export var lobbyOutAnimationPlayer : AnimationPlayer
@export var chipHolder : ChipHolder
@export var maxLobbyTime := 50.0

var monigotes : Array[Monigote]

func _ready():
	if DebugVars.straigtToArena:
		maxLobbyTime = .1
	
	$Maletin/AnimationPlayer.play("MaletinAAction_001")
	
	if multiplayer.is_server():
		monigotes = PlayerHandler.instantiatePlayers()
		
		var xPos = -3
		for m : Monigote in monigotes:
			xPos += 1
			get_parent().add_child.call_deferred(m, true)
			m.position = to_global(Vector3(xPos, Globals.SPRITE_HEIGHT, -3))
	
	get_tree().create_timer(maxLobbyTime).timeout.connect(func():
		if lobbyOutAnimationPlayer.is_playing():
			return
		
		for mon in monigotes:
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
	
	await create_tween().tween_property(body, "global_position", to_global($JumpPosition.position), .1).finished
	
	chipHolder.ownMonigote(body)
	monigotes.erase(body)
	
	if monigotes.is_empty():
		startExitAnimation()

func startExitAnimation():
	lobbyOutAnimationPlayer.play("LobbyOutAnimation")
	$Maletin/AnimationPlayer.play_backwards("MaletinAAction_001")

func _on_multiplayer_spawner_spawned(node):
	if node is Monigote:
		monigotes.append(node)
