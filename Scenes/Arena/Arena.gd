extends Node3D
class_name Arena

signal effectStarted(effect)
signal gameEnded(winner) # winner : Monigote

@onready var effects : Array = $Effects.get_children()

@export var dieScene : PackedScene
var die : Die

@export var dieScreenShakeMagnitude := .6
@export var dieScreenShakeTime := .3

const WIDTH  : float = 11
const HEIGHT : float = 6.4

# Active effect va de 0 a 5
var activeEffect   : int = -1

var monigotes : Array[Monigote]

var betting := true

func _ready():
	$Lobby.startBetting.connect(goToBettingScene)

func _process(delta):
	if betting:
		return
	
	if activeEffect != -1:
		effects[activeEffect].update(delta)
	
	BetHandler.arenaUpdate(delta)

func recieveMonigote(mon : Monigote) -> void:
	monigotes.append(mon)
	mon.reparent(self)
	mon.set_process(true)
	mon.set_physics_process(true)
	mon.died.connect(onMonigoteDeath.bind(mon))

func startArena():
	# Las paredes tienen que empezar desactivadas para que pueda haber monigotes fuera de la arena
	for wallCollision in $Walls.get_children():
		wallCollision.disabled = false

	BetHandler.startGame(self)

	for e in effects:
		e.create(self)

	%MultipleResCamera.startGameAnimation()

	# Delay hasta que entra el dado
	await get_tree().create_timer(2).timeout

	betting = false
	
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
	effects[activeEffect].end()
	activeEffect = -1
	
	$PrepareArrow.visible = false
	
	betting = true
	die.queue_free()
	
	var winnerId = winnerMon.player.id
	winnerMon.set_physics_process(false)
	%MultipleResCamera.zoomTo(winnerMon.position)
	await get_tree().create_timer(3).timeout
	
	goToLeaderboard(winnerId)

	for mon in monigotes:
		mon.queue_free()
	monigotes.clear()

func goToLeaderboard(winnerId):
	%MultipleResCamera.startLeaderboardAnimation().tween_callback(
		$ChipHolder.startLeaderboardAnimation.bind(winnerId)
	)

func goToBettingScene():
	$BetDisplaySimple.startBetting()
	%MultipleResCamera.startBettingAnimation()

func startEffect(n : int):
	%MultipleResCamera.startShake(dieScreenShakeMagnitude,dieScreenShakeTime)
	
	activeEffect = n
	effects[activeEffect].start()
	
	# Animación del nombre del efecto
	$CurrentBetName.visible = true
	$CurrentBetName.position = die.position + Vector3.BACK
	$CurrentBetName.position.y = 1.4
	$CurrentBetName.text = str(activeEffect + 1) + ". " + effects[activeEffect].effectName
	
	var animationTime = .5
	var waitTime = 1
	
	var nameSizeTween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	nameSizeTween.tween_property($CurrentBetName, "scale", Vector3.ONE, animationTime)
	nameSizeTween.tween_interval(waitTime)
	nameSizeTween.tween_property($CurrentBetName, "scale", Vector3.ZERO, animationTime)
	
	nameSizeTween.connect("finished", func(): $CurrentBetName.visible = false)
	
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

func getRandomPosition(padding := 1) -> Vector3:
	return Vector3(randf_range(-WIDTH/2 + padding, WIDTH/2 - padding),
		Globals.SPRITE_HEIGHT,
		randf_range(-HEIGHT/2 + padding, HEIGHT/2 - padding))

func onMonigoteDeath(mon : Monigote):
	monigotes.erase(mon)
	
	if monigotes.size() == 1:
		endGame(monigotes[0])
	if monigotes.size() == 0:
		endGame(mon)

func getMainLight() -> DirectionalLight3D:
	return $DirectionalLight3D

func getHiResTexture() -> ViewportTexture:
	return $MultipleResCamera.getHiResTexture()

func getLowResTexture() -> ViewportTexture:
	return $MultipleResCamera.getLowResTexture()

func getFullTexture() -> ViewportTexture:
	return $MultipleResCamera.getFullTexture()

## Dado un punto en el mundo 3d, devuelve la posición 2d que ocupa ese punto en pantalla 
func getScreenPos(pos3d : Vector3) -> Vector2:
	return $MultipleResCamera.unproject_position(pos3d)
