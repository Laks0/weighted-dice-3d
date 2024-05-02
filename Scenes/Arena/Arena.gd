extends Node3D
class_name Arena

signal effectStarted(effect)
signal gameEnded(winner) # winner : playerId

var effects : Array

@export var dieScene : PackedScene
var die : Die

@export var dieScreenShakeMagnitude := .6
@export var dieScreenShakeTime := .3

@export var cardShowAnimationScene : PackedScene

const WIDTH  : float = 11
const HEIGHT : float = 6.4

# Active effect va de 0 a 5
var activeEffect   : int = -1

var monigotes : Array[Monigote]

var gameRunning := false

func _ready():
	startNewGame()

func startNewGame():
	$Effects.pickEffects()
	effects = $Effects.get_children()
	for e in effects:
		e.create(self)

func _process(delta):
	if %StageHandler.currentStage != StageHandler.Stages.ARENA:
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
	BetHandler.startGame(self)
	
	%MultipleResCamera.startGameAnimation()
	
	if BetHandler.round == 1 and not DebugVars.skipCardAnimation:
		var cardAnimation : AnimationPlayer = cardShowAnimationScene.instantiate()
		cardAnimation.effects = effects
		cardAnimation.arena = self
		add_child(cardAnimation)
		await cardAnimation.animation_finished
		cardAnimation.queue_free()
	
	for mon in monigotes:
			mon.set_process(true)
			mon.set_physics_process(true)
	
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
		%MultipleResCamera.showSlotMachine()
		if activeEffect != -1:
			effects[activeEffect].end())
	die.dropped.connect(%MultipleResCamera.returnToArena)

func endGame(winnerMon : Monigote):
	SoundtrackHandler.stopTrack()
	lightsOn() # Por si acaso
	
	effects[activeEffect].end()
	activeEffect = -1
	
	gameRunning = false
	
	await get_tree().create_timer(.3).timeout
	SoundtrackHandler.playTrack(0)
	
	$PrepareArrow.visible = false
	
	if is_instance_valid(die):
		die.queue_free()
	
	var winnerId = winnerMon.player.id
	winnerMon.set_physics_process(false)
	%MultipleResCamera.zoomTo(winnerMon.position)
	await get_tree().create_timer(3).timeout
	
	gameEnded.emit(winnerId)

func startEffect(n : int):
	%MultipleResCamera.startShake(dieScreenShakeMagnitude,dieScreenShakeTime)
	
	activeEffect = n
	effects[activeEffect].start()
	
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
	monigotes.erase(mon)
	
	if not gameRunning:
		return
	
	if monigotes.size() == 1:
		endGame(monigotes[0])
	if monigotes.size() == 0:
		endGame(mon)

func lightsOff():
	var lightTween := get_tree().create_tween().parallel()
	lightTween.tween_property($DirectionalLight3D, "light_energy", .3, 1)
	$GlobalLight.visible = false
	lightTween.set_ease(Tween.EASE_OUT)

func lightsOn():
	var lightTween := get_tree().create_tween().parallel()
	lightTween.tween_property($DirectionalLight3D, "light_energy", 1, 1)
	$GlobalLight.visible = true
	lightTween.set_ease(Tween.EASE_OUT)

func fogOn(density : float = .01, time : float = .5):
	var env : Environment = $WorldEnvironment.environment
	env.volumetric_fog_enabled = true
	var tween := get_tree().create_tween()
	tween.tween_property(env, "volumetric_fog_density", density, time)

func fogOff(time : float = .5):
	var env : Environment = $WorldEnvironment.environment
	var tween := get_tree().create_tween()
	tween.tween_property(env, "volumetric_fog_density", 0, time)

## Dado un punto en el mundo 3d, devuelve la posición 2d que ocupa ese punto en pantalla 
func getScreenPos(pos3d : Vector3) -> Vector2:
	return $MultipleResCamera.unproject_position(pos3d)

## PLACEHOLDER
func changeWallHue(color : Color):
	var tween = create_tween()
	tween.tween_property($Floor/Mesa/MesaEx/MesaInt, "material_override:albedo_color", color, .5)
