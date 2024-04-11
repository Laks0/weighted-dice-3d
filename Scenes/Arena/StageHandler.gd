## Desde acá se manejan las transiciones entre estados de juego (lobby, apuestas, partida)
## El StageHandler es responsable de la comunicación entre stages y de mantener
## a los monigotes, avisándole a cada stage cuándo es su responsabilidad manejarlos

extends Node
class_name StageHandler

@export var arena : Arena
@export var lobby : Briefcase
@export var chipHolder : ChipHolder
@export var betDisplay : BetDisplaySimple

@export var camera : MultipleResCamera

@export var betCamera : Camera3D
@export var leaderboardCamera : Camera3D

enum Stages {LOBBY, BETTING, ARENA, LEADERBOARD, TRANSITION}
var currentStage := Stages.LOBBY

var monigotes : Array[Monigote]

func _ready():
	await arena.ready
	createMonigotes()
	lobby.positionMonigotes(monigotes)
	lobby.monigoteReady.connect(onLobbyMonigoteReady)
	
	betDisplay.allPlayersReady.connect(betToArena)
	
	arena.gameEnded.connect(arenaToLeaderboard)
	
	chipHolder.nextRound.connect(leaderboardToBet)
	chipHolder.resetRequest.connect(resetGame)
	
	arena.setTableRender(false)
	# Las paredes de la arena tienen que empezar desabilitadas para poder tener monigotes fuera
	arena.setWallsDisabled(true)

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
# Se llama desde la animación de lobbyOut
func lobbyToBet():
	arena.setTableRender(true)
	camera.goToCamera(betCamera).finished.connect(func(): 
		betDisplay.startBetting()
		currentStage = Stages.BETTING
	)

func betToArena():
	currentStage = Stages.TRANSITION
	chipHolder.disownAllMonigotes()
	for mon in monigotes:
		jumpMonigoteTo(mon, Vector3(mon.position.x, Globals.SPRITE_HEIGHT, 0))
	await camera.startGameAnimation().finished
	
	chipHolder.visible = false
	arena.setWallsDisabled(false)
	arena.recieveMonigotes(monigotes)
	arena.startArena()
	currentStage = Stages.ARENA

func arenaToLeaderboard(winnerId):
	currentStage = Stages.LEADERBOARD
	# Resetea los monigotes
	# IMPORTANTE: todavía no se llamó settleBet, entonces si un jugador se quedó
	# sin fichas esta ronda, igualmente se crea su monigote, se tiene que eliminar
	# antes de la próxima ronda
	destroyMonigotes()
	createMonigotes()
	for mon in monigotes:
		chipHolder.ownMonigote(mon)
	
	chipHolder.visible = true
	camera.goToCamera(leaderboardCamera)\
		.finished.connect(chipHolder.startLeaderboardAnimation.bind(winnerId))

func leaderboardToBet():
	for mon in monigotes:
		if not mon.player.isStillPlaying():
			chipHolder.disownMonigote(mon)
			mon.queue_free()
	
	monigotes = chipHolder.ownedMonigotes.duplicate()
	
	arena.setTableRender(true)
	camera.goToCamera(betCamera).finished.connect(func(): 
		betDisplay.startBetting()
		currentStage = Stages.BETTING
	)

func resetGame():
	PlayerHandler.resetAllPlayers()
	BetHandler.round = 0
	arena.startNewGame()
	
	chipHolder.disownAllMonigotes()
	destroyMonigotes()
	createMonigotes()
	for mon in monigotes:
		chipHolder.ownMonigote(mon)

######################
# Funciones de lobby #
######################
var lobbyMonigotesReady := 0
func onLobbyMonigoteReady(mon : Monigote):
	mon.set_process(false)
	mon.set_physics_process(false)
	
	await jumpMonigoteTo(mon, chipHolder.getPositionForMonigote(mon.player.id)).finished
	chipHolder.ownMonigote(mon)
	lobbyMonigotesReady += 1
	
	if lobbyMonigotesReady == PlayerHandler.getPlayersAlive().size():
		$LobbyOutAnimationPlayer.play("LobbyOutAnimation")
		$LobbyOutAnimationPlayer.animation_finished.connect(lobby.queue_free.unbind(1))
