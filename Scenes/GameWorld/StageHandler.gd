## Desde acá se manejan las transiciones entre estados de juego (lobby, apuestas, partida)
## El StageHandler es responsable de la comunicación entre stages y de mantener
## a los monigotes, avisándole a cada stage cuándo es su responsabilidad manejarlos

extends Node3D
class_name StageHandler

signal inLeaderboard
signal inArena
signal inBetting

@export var arena : Arena
@export var lobby : Briefcase
@export var chipHolder : ChipHolder
@export var betDisplay : BetDisplaySimple

@export var camera : MultipleResCamera

@export var betCamera : Camera3D
@export var leaderboardCamera : Camera3D
@export var arenaCamera : Camera3D

enum Stages {LOBBY, BETTING, ARENA, LEADERBOARD, TRANSITION}
var currentStage := Stages.LOBBY

var monigotes : Array[Monigote]

func _ready():
	BetHandler.resetGame()
	
	betDisplay.allPlayersReady.connect(goToArena)
	
	arena.stageFinished.connect(arenaToLeaderboard)
	
	chipHolder.nextRound.connect(leaderboardToBet)
	chipHolder.resetRequest.connect(resetGame)
	
	arena.setTableRender(false)
	# Las paredes de la arena tienen que empezar desabilitadas para poder tener monigotes fuera
	arena.setWallsDisabled(true)
	
	createMonigotes()
	lobby.positionMonigotes(monigotes)
	lobby.monigoteReady.connect(onLobbyMonigoteReady)
	
	if Debug.vars.skipLobby:
		lobbyToArena()

## Crea los monigotes necesarios y los pone en Arena.
## IMPORTANTE: para evitar problemas de path, los monigotes siempre son hijos directos de Arena
func createMonigotes():
	monigotes = PlayerHandler.instantiatePlayers()
	for m in monigotes:
		arena.add_child(m)

func destroyMonigotes():
	for mon in monigotes:
		if is_instance_valid(mon):
			mon.queue_free()
	monigotes.clear()

func destroyMonigotesOfLoosingPlayers():
	monigotes = monigotes.filter(func (mon : Monigote): 
		if mon.player.isStillPlaying():
			return true
		mon.queue_free()
		return false
	)

## Hace saltar el monigote desde su posición a pos (global)
func jumpMonigoteTo(monigote : Monigote, pos : Vector3) -> Tween:
	var height := 5.0
	var jumpCurve = Curve3D.new()
	jumpCurve.add_point(monigote.global_position)
	jumpCurve.add_point(pos, Vector3(0,height,0))

	var jumpTween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	jumpTween.tween_method(func (t):
		monigote.global_position = jumpCurve.sample(0, t),
		0.0, 1.0, .5)
	return jumpTween

###########################
# Funciones de transición #
###########################
## La transición para ir a la arena es la misma viniendo desde cualquier stage
## Desde el lobby se llama en la animación de lobbyOut
func goToArena():
	currentStage = Stages.TRANSITION
	chipHolder.disownAllMonigotes()
	arena.setTableRender(true)
	arena.clearArena()
	
	await camera.goToCamera(arenaCamera, .4).finished
	
	chipHolder.visible = false
	arena.setWallsDisabled(false)
	
	arena.startArena()
	BetHandler.startGame(arena)
	destroyMonigotes()
	currentStage = Stages.ARENA
	inArena.emit()

func lobbyToArena():
	destroyMonigotes()
	
	$LobbyOutAnimationPlayer.play("LobbyOutAnimation")
	$LobbyOutAnimationPlayer.animation_finished.connect(lobby.queue_free.unbind(1))

## Cuánto se mueve en y el bet display para que no moleste a la cámara del leaderboard
var betDisplayDisplacement := -1.5
@onready var betDisplayHeight := betDisplay.position.y

func arenaToLeaderboard(winnerId):
	currentStage = Stages.LEADERBOARD
	# Resetea los monigotes
	# IMPORTANTE: todavía no se llamó settleBet, entonces si un jugador se quedó
	# sin fichas esta ronda, igualmente se crea su monigote, se tiene que eliminar
	# antes de la próxima ronda
	destroyMonigotes()
	createMonigotes()
	for mon in monigotes:
		mon.freeze()
		chipHolder.ownMonigote(mon)
	
	# Saco al bet display para que no moleste con el leaderboard
	create_tween().tween_property(betDisplay, "position:y", betDisplayDisplacement, .3).as_relative()
	
	chipHolder.visible = true
	inLeaderboard.emit()
	await camera.goToCamera(leaderboardCamera).finished
	chipHolder.startLeaderboardAnimation(winnerId)
	SoundtrackHandler.playTrack(6)

func leaderboardToBet():
	currentStage = Stages.TRANSITION
	
	destroyMonigotesOfLoosingPlayers()
	
	arena.setTableRender(false)
	
	# Hay que poner a betDisplay en su lugar (se saca en arenaToLeaderboard)
	#create_tween().tween_property(betDisplay, "position:y", -betDisplayHeight, .1)
	# Por alguna razón tweeneando no funciona pero así sí
	betDisplay.position.y = betDisplayHeight
	
	betDisplay.startBetting()
	$NewBetShow.setDisplayBet(BetHandler.currentBet)
	$NewBetShow/SpotLight3D.visible = true
	await $NewBetShow.startAnimation(camera)
	
	await get_tree().create_timer(10).timeout
	
	#await betDisplay.showBetNameAnimation(camera)
	
	arena.setTableRender(true)
	
	currentStage = Stages.BETTING
	
	await camera.goToCamera(betCamera).finished
	$BetDisplaySimple._startOddsAnimations()
	$NewBetShow/SpotLight3D.visible = false
	inBetting.emit()

func resetGame():
	PlayerHandler.resetAllPlayers()
	BetHandler.resetGame()
	
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen/LoadingScreen.tscn")

func restartRound():
	BetHandler.resetRound()
	goToArena()

######################
# Señal desde lobby #
######################
var lobbyMonigotesReady := 0
func onLobbyMonigoteReady(mon : Monigote):
	lobbyMonigotesReady += 1
	
	chipHolder.showChipDisplay(mon.player.id)
	
	if lobbyMonigotesReady < PlayerHandler.getPlayersAlive().size():
		return
	
	lobbyToArena()
