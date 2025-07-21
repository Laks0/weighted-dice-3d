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

# Active effect va de 0 a 5
var activeEffect   : int = -1

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
	
	if activeEffect != -1:
		effects[activeEffect].update(delta)
	
	BetHandler.arenaUpdate(delta)

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
	add_child(die)
	
	die.prepareArrow = $PrepareArrow
	die.rolled.connect(startEffect)
	die.onCubilete.connect(func():
		multipleResCamera.goToCamera($CubileteCamera)
		if activeEffect != -1:
			effects[activeEffect].end())
	die.dropped.connect(func():
		multipleResCamera.goToCamera($RolledNumberCamera)
		await get_tree().create_timer(timeBeforeStartingEffect).timeout
		multipleResCamera.goToCamera($ArenaCamera)
	)
	
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
	
	effects[activeEffect].end()
	activeEffect = -1
	
	gameRunning = false
	
	await get_tree().create_timer(.3).timeout
	SoundtrackHandler.playTrack(5)
	
	$PrepareArrow.visible = false
	
	if is_instance_valid(die):
		die.queue_free()
	
	winnerMon.freeze()
	multipleResCamera.zoomTo(winnerMon.position)
	await get_tree().create_timer(3).timeout
	
	stageFinished.emit(winnerId)

func startEffect(n : int):
	multipleResCamera.startShake(dieScreenShakeMagnitude,dieScreenShakeTime)
	for i in Input.get_connected_joypads():
		Input.start_joy_vibration(i, .6, .6, dieScreenShakeTime)
	
	activeEffect = n
	Narrator.announceEffect(effects[activeEffect].effectName)
	# Animación del nombre del efecto
	$CurrentEffectName.visible = true
	$CurrentEffectName.position = die.position + Vector3.BACK
	$CurrentEffectName.position.y = 1.4
	$CurrentEffectName.text = str(activeEffect + 1) + ". " + effects[activeEffect].effectName
	
	var animationTime = .5
	var waitTime = 1
	
	var nameSizeTween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	nameSizeTween.tween_property($CurrentEffectName, "scale", Vector3.ONE, animationTime)
	nameSizeTween.tween_interval(waitTime)
	nameSizeTween.tween_property($CurrentEffectName, "scale", Vector3.ZERO, animationTime)
	
	nameSizeTween.connect("finished", func(): $CurrentEffectName.visible = false)
	
	await get_tree().create_timer(timeBeforeStartingEffect).timeout
	effects[activeEffect].start()
	
	emit_signal("effectStarted", effects[activeEffect])

# Esta función queda Legacy pero sigue teniendo sentido como un getter
func getLivingMonigotes() -> Array[Monigote]:
	return monigotes

func getRandomMonigote() -> Monigote:
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

func getRandomPosition(padding := 1, yPos : float = .1) -> Vector3:
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
