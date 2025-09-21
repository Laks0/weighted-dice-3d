extends Node3D
class_name Arena

@warning_ignore("unused_signal")
signal effectStarted(effect)
signal gameStarted
signal gameEnded
signal stageFinished(winner) # winner : playerId

var effects : Array

@export var dieScene : PackedScene
var die : Die

@export var dieScreenShakeMagnitude := .6
@export var dieScreenShakeTime := .3
@export var timeBeforeStartingEffect := 1.0

@export var cardShowAnimationScene : PackedScene

const WIDTH  : float = 11
const HEIGHT : float = 6.4

var monigotes : Array[Monigote]

var gameRunning := false

@export var stageHandler : StageHandler
@export var multipleResCamera : MultipleResCamera
@export var environment : WorldEnvironment

func _ready():
	$Effects.pickEffects()
	effects = $Effects.get_children()
	for e in effects:
		e.create(self)

func _process(delta):
	if stageHandler.currentStage != StageHandler.Stages.ARENA:
		return
	
	BetHandler.arenaUpdate(delta)

func currentStage() -> StageHandler.Stages:
	return stageHandler.currentStage

func recieveMonigotes(arr : Array[Monigote]) -> void:
	monigotes = arr
	for mon in monigotes:
		mon.died.connect(onMonigoteDeath.bind(mon))
		mon.arenaReady()

func setWallsDisabled(val : bool) -> void:
	for wallCollision in $Walls.get_children():
		wallCollision.disabled = val

func setTableRender(val : bool) -> void:
	$Floor.visible = val

# Se llama para empezar la ronda de juego
func startArena():
	if BetHandler.round == 1 and not Debug.vars.skipCardAnimation:
		multipleResCamera.goToCamera($CardsCamera, .1)
		var cardAnimation : AnimationPlayer = cardShowAnimationScene.instantiate()
		cardAnimation.effects = effects
		cardAnimation.environment = environment
		add_child(cardAnimation)
		await cardAnimation.animation_finished
		cardAnimation.queue_free()
		multipleResCamera.goToCamera($ArenaCamera)
	
	
	for mon in monigotes:
		mon.unfreeze()
	
	if Debug.vars.dontStartGame:
		return
	
	# Delay hasta que entra el dado
	SoundtrackHandler.stopTrack()
	await get_tree().create_timer(2).timeout
	SoundtrackHandler.playTrack(1)
	
	gameRunning = true
	
	die = dieScene.instantiate()
	die.position.y = 1
	die.position = Vector3(0, 1, 0)
	add_child(die)
	
	die.rolled.connect(dieRolled)
	die.rolled.connect($Effects.startEffect)
	die.onCubilete.connect(func():
		multipleResCamera.goToCamera($CubileteCamera)
		$Effects.stopActiveEffect())
	die.dropped.connect(func():
		multipleResCamera.goToCamera($RolledNumberCamera)
		await get_tree().create_timer(timeBeforeStartingEffect).timeout
		multipleResCamera.goToCamera($ArenaCamera)
	)
	
	$Effects.currentEffectFinished.connect(die._onCurrentEffectFinished)
	$Effects.effectStarted.connect(die._onEffectStarted)
	
	gameStarted.emit()

func endGame(winnerMon : Monigote):
	var winnerId = winnerMon.player.id
	var skinName = PlayerHandler.getSkinName(winnerId)
	if skinName == "Male" or skinName == "Marta":
		Narrator.playBank("roundend", 2)
	else:
		Narrator.playBank("roundend", 1)
	winnerMon.hasWon.emit()
	SoundtrackHandler.stopTrack()
	environment.lightsOn() # Por si acaso
	
	gameEnded.emit()
	BetHandler.endGame()
	
	$Effects.stopActiveEffect()
	
	gameRunning = false
	
	await get_tree().create_timer(.3).timeout
	SoundtrackHandler.playTrack(5)
	
	if is_instance_valid(die):
		die.queue_free()
	
	winnerMon.freeze()
	multipleResCamera.zoomTo(winnerMon.position)
	await get_tree().create_timer(3).timeout
	
	stageFinished.emit(winnerId)

func dieRolled(n : int):
	# Animación del nombre del efecto
	$CurrentEffectName.visible = true
	$CurrentEffectName.position = die.position + Vector3.BACK
	$CurrentEffectName.position.y = 1.4
	$CurrentEffectName.text = str(n + 1) + ". " + $Effects.getEffect(n).effectName
	
	var animationTime = .5
	var waitTime = 1
	
	var nameSizeTween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	nameSizeTween.tween_property($CurrentEffectName, "scale", Vector3.ONE, animationTime)
	nameSizeTween.tween_interval(waitTime)
	nameSizeTween.tween_property($CurrentEffectName, "scale", Vector3.ZERO, animationTime)
	
	nameSizeTween.connect("finished", func(): $CurrentEffectName.visible = false)

# Esta función queda Legacy pero sigue teniendo sentido como un getter
func getLivingMonigotes() -> Array[Monigote]:
	return monigotes

func getRandomMonigote() -> Monigote:
	if monigotes.is_empty():
		return Monigote.new()
	return monigotes[randi() % len(monigotes)]

func getClosestMonigote(from : Vector3, exclude : Array = []) -> Monigote:
	var closest : Monigote
	var minDistance : float = 10000
	for monigote : Monigote in getLivingMonigotes():
		if exclude.has(monigote):
			continue
		var distance = from.distance_to(monigote.position)
		if distance < minDistance:
			minDistance = distance
			closest = monigote

	return closest

func getRandomPosition(padding : float = 1, yPos : float = .1) -> Vector3:
	return Vector3(randf_range(-WIDTH/2 + padding, WIDTH/2 - padding),
		yPos,
		randf_range(-HEIGHT/2 + padding, HEIGHT/2 - padding))

func onMonigoteDeath(mon : Monigote):
	Narrator.announceKill("generic")
	monigotes.erase(mon)
	
	if not gameRunning:
		return
	
	if monigotes.size() == 1:
		endGame(monigotes[0])
	if monigotes.size() == 0:
		endGame(mon)



## PLACEHOLDER
func changeWallHue(color : Color):
	var tween = create_tween()
	tween.tween_property($Floor/Mesa/MesaEx/MesaInt, "material_override:albedo_color", color, .5)
