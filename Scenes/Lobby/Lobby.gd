extends Node3D
class_name Briefcase

# Señales que escucha el stageHandler
signal monigoteReady(mon)
signal monigoteUnready(mon)

@export var lobbyOutAnimationPlayer : AnimationPlayer
@export var maxLobbyTime := 50.0

@export var buttonHintScene : PackedScene
@export var maletin_abre : AudioStreamWAV
@export var maletin_cierra : AudioStreamWAV

@export var readyChipScene : PackedScene

## Dada la lista de monigotes, los posiciona en el lobby (con posiciones globales)
func positionMonigotes(mons : Array[Monigote]) -> void:
	var xPos = -3
	for m : Monigote in mons:
		m.global_position = to_global(Vector3(xPos, Globals.SPRITE_HEIGHT, -3))
		xPos += 1
	
	for mon : Monigote in mons:
		var device = mon.player.inputController
		mon.beenGrabbed.connect(func():
			var hint :AnimatedSprite3D= buttonHintScene.instantiate()
			
			mon.add_child(hint)
			hint.position = Vector3(0,1,0)
			
			if device == Controllers.KB:
				hint.play("kb")
			elif device == Controllers.KB2:
				hint.play("kb_alt")
			else:
				hint.play("xbox")
			
			mon.escaped.connect(hint.queue_free)
			mon.wasPushed.connect(hint.queue_free.unbind(3))
		)

func _ready():
	if DebugVars.straigthToArena:
		maxLobbyTime = 0
	
	var i = 0
	for id in PlayerHandler.getPlayersAliveById():
		var chip = readyChipScene.instantiate()
		chip.position = Vector3(-3 + i, .3, -8)
		chip.playerId = id
		add_child(chip)
		i += 1
	
	$Maletin/AnimationPlayer.play("MaletinAAction_001")
	$Maletin/AudioStreamPlayer.stream = maletin_abre
	$Maletin/AudioStreamPlayer.play()

func startExitAnimation():
	$Maletin/AudioStreamPlayer.stream = maletin_cierra
	get_tree().create_timer(.5).timeout.connect($Maletin/AudioStreamPlayer.play)
	$Maletin/AnimationPlayer.play_backwards("MaletinAAction_001")
