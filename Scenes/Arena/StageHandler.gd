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
	
	betDisplay.allPlayersReady.connect(goToArena)
	
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
## La transición para ir a la arena es la misma viniendo desde cualquier stage
## Desde el lobby se llama en la animación de lobbyOut
func goToArena():
	currentStage = Stages.TRANSITION
	chipHolder.disownAllMonigotes()
	arena.setTableRender(true)
	
	for mon in monigotes:
		jumpMonigoteTo(mon, Vector3(mon.position.x, Globals.SPRITE_HEIGHT, 1.5))
	
	# Delay del monigote saltando antes de que cambie la cámara
	await get_tree().create_timer(.1).timeout
	
	await camera.startGameAnimation().finished
	
	chipHolder.visible = false
	arena.setWallsDisabled(false)
	arena.recieveMonigotes(monigotes)
	
	BetHandler.startGame(arena)
	arena.startArena()
	currentStage = Stages.ARENA

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
	await camera.goToCamera(leaderboardCamera).finished
	chipHolder.startLeaderboardAnimation(winnerId)

func leaderboardToBet():
	currentStage = Stages.TRANSITION
	# Hace falta matar a los monigotes que perdieron, avisarle a chipHolder que
	# no existen más, y eliminarlos de nuestra lista. Para eso lo hacemos desde
	# chipHolder y después copiamos el resultado de ahí
	for mon in monigotes:
		if not mon.player.isStillPlaying():
			chipHolder.disownMonigote(mon)
			mon.queue_free()
	monigotes = chipHolder.ownedMonigotes.duplicate()
	
	# Hay que poner a betDisplay en su lugar (se saca en arenaToLeaderboard)
	#create_tween().tween_property(betDisplay, "position:y", -betDisplayHeight, .1)
	# Por alguna razón tweeneando no funciona pero así sí
	betDisplay.position.y = betDisplayHeight
	
	arena.setTableRender(true)
	betDisplay.startBetting()
	
	await camera.goToCamera(betCamera).finished
	
	currentStage = Stages.BETTING

func resetGame():
	PlayerHandler.resetAllPlayers()
	BetHandler.resetGame()
	#arena.startNewGame()
	#
	#chipHolder.disownAllMonigotes()
	#destroyMonigotes()
	#createMonigotes()
	#for mon in monigotes:
		#chipHolder.ownMonigote(mon)
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen/LoadingScreen.tscn")

######################
# Señal desde lobby #
######################
var lobbyMonigotesReady := 0
func onLobbyMonigoteReady(mon : Monigote):
	lobbyMonigotesReady += 1
	if lobbyMonigotesReady < PlayerHandler.getPlayersAlive().size():
		return
	
	for m : Monigote in monigotes:
		m.freeze()
		
		# Hacemos el salto del último por separado para poder hacer un wait
		if m == mon:
			continue
		
		jumpMonigoteTo(m, chipHolder.getPositionForMonigote(m.player.id)).finished.connect(
			chipHolder.ownMonigote.bind(m)
		)
	
	await jumpMonigoteTo(mon, chipHolder.getPositionForMonigote(mon.player.id)).finished
	chipHolder.ownMonigote(mon)
	
	$LobbyOutAnimationPlayer.play("LobbyOutAnimation")
	$LobbyOutAnimationPlayer.animation_finished.connect(lobby.queue_free.unbind(1))
