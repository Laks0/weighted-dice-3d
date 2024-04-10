extends Node3D
class_name Briefcase

signal monigoteReady(mon)

@export var lobbyOutAnimationPlayer : AnimationPlayer
@export var maxLobbyTime := 50.0

var monigotes : Array[Monigote]

## Dada la lista de monigotes, los posiciona en el lobby (con posiciones globales)
func positionMonigotes(mons : Array[Monigote]) -> void:
	var xPos = -3
	for m : Monigote in mons:
		m.global_position = to_global(Vector3(xPos, Globals.SPRITE_HEIGHT, -3))
		xPos += 1

func _ready():
	if DebugVars.straigtToArena:
		maxLobbyTime = 0
	
	$Maletin/AnimationPlayer.play("MaletinAAction_001")
	
	get_tree().create_timer(maxLobbyTime).timeout.connect(func():
		if lobbyOutAnimationPlayer.is_playing():
			return
		
		for mon in monigotes:
			if mon.get_parent() != self:
				continue
			monigoteReady.emit(mon)
	)

func _on_ready_area_body_entered(body):
	if not body is Monigote:
		return
	
	if not body.is_processing():
		return
	
	body.set_process(false)
	body.set_physics_process(false)
	
	await create_tween().tween_property(body, "position", to_global($JumpPosition.position), .1).finished
	
	monigoteReady.emit(body)

func startExitAnimation():
	$Maletin/AnimationPlayer.play_backwards("MaletinAAction_001")
