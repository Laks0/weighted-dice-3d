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

enum Stages {LOBBY, BETTING, ARENA}
var currentStage := Stages.LOBBY

var monigotes : Array[Monigote]

func _ready():
	await arena.ready
	createMonigotes()
	lobby.positionMonigotes(monigotes)
	lobby.monigoteReady.connect(onLobbyMonigoteReady)

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
	camera.goToCamera(betCamera)\
			.finished.connect(betDisplay.startBetting)
	currentStage = Stages.BETTING

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
