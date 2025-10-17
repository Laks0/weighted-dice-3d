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

func _spawnMonigotes():
	monigotes = PlayerHandler.instantiatePlayers()
	
	var startingPos = -WIDTH/2 + 1
	var spaceBetweenMonigotes := (WIDTH - 2)/(monigotes.size()-1)
	
	for i in range(monigotes.size()):
		monigotes[i].position = Vector3(startingPos + spaceBetweenMonigotes*i, 10, 2)
		monigotes[i].died.connect(onMonigoteDeath.bind(monigotes[i]))
		add_child(monigotes[i])
		monigotes[i].freeze()
		monigotes[i].arenaReady()
		var tween := create_tween()
		tween.tween_interval(i*.2+.2)
		tween.tween_property(monigotes[i], "position:y", 0, .1)
		tween.tween_callback(monigotes[i].unfreeze)
		
		var stunTime := (monigotes.size()-1-i)*.2+.3+i*.07
		var direction := Vector2.from_angle(randf() * 2*PI)
		tween.tween_callback(monigotes[i].movement.stun.bind(stunTime, direction))

func setWallsDisabled(val : bool) -> void:
	for wallCollision in $Walls.get_children():
		wallCollision.disabled = val

func setTableRender(val : bool) -> void:
	$Floor.visible = val

# Se llama para empezar la ronda de juego
func startArena():
	#if BetHandler.round == 1 and not Debug.vars.skipCardAnimation:
		#multipleResCamera.goToCamera($CardsCamera, .1)
		#var cardAnimation : AnimationPlayer = cardShowAnimationScene.instantiate()
		#cardAnimation.effects = effects
		#cardAnimation.environment = environment
		#add_child(cardAnimation)
		#await cardAnimation.animation_finished
		#cardAnimation.queue_free()
		#multipleResCamera.goToCamera($ArenaCamera)
	
	_spawnMonigotes()
	
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
	
	clearArena()
	stageFinished.emit(winnerId)

func clearArena():
	$Effects.stopActiveEffect()
	SoundtrackHandler.stopTrack()
	environment.lightsOn() # Por si acaso
	if is_instance_valid(die):
		die.queue_free()
	for mon in monigotes:
		if is_instance_valid(mon):
			mon.queue_free()
	monigotes.clear()
	gameRunning = false

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

func sampleRandomPositions(n : int, minDistance : float = 1, padding : float = 1, yPos : float = .1) -> PackedVector3Array:
	var res : PackedVector3Array
	var grid : Dictionary[Vector2i, bool]
	
	var realHalfWidth  := WIDTH/2 - padding
	var realHalfHeight := HEIGHT/2 - padding
	
	var gridHalfWidth : int = floor(realHalfWidth/minDistance)
	var gridHalfHeight : int = floor(realHalfHeight/minDistance)
	
	for x in range(-gridHalfWidth, gridHalfWidth+1):
		for y in range(-gridHalfHeight, gridHalfHeight+1):
			grid.set(Vector2i(x,y), true)
	
	for _i in range(n):
		var pick = grid.keys().pick_random()
		var vec3pick := Vector3(pick.x, 0, pick.y) * minDistance + Vector3(0, yPos, 0)
		res.append(vec3pick)
		for dx in range(-1,2):
			for dy in range(-1,2):
				grid.erase(pick + Vector2i(dx,dy))
	
	return res

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
func changeWallHue(_color : Color):
	pass
	#var tween = create_tween()
	#tween.tween_property($Floor/Mesa/Mesa_v2, "material_override:albedo_color", color, .5)
