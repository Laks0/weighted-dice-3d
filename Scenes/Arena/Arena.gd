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
var monigotesAlive : int = 0

var monigotes : Array[Monigote]

var betting := true

func _ready():
	$Lobby.startBetting.connect(func ():
		%MultipleResCamera.startBettingAnimation()
		$BetDisplaySimple.startBetting())

func _process(delta):
	if betting:
		return
	
	if activeEffect != -1:
		effects[activeEffect].update(delta)
	
	BetHandler.arenaUpdate(delta)

func startArena():
	betting = false
	
	die = dieScene.instantiate()
	die.position.y = 1
	add_child(die)
	
	monigotes = PlayerHandler.instantiatePlayers()
	monigotesAlive = len(monigotes)
	
	var xPos = -1
	for m in monigotes:
		m.position = Vector3(xPos, Globals.SPRITE_HEIGHT, 1)
		xPos += 1
		add_child(m)
		m.died.connect(onMonigoteDeath.bind(m))
	
	# Las paredes tienen que empezar desactivadas para que pueda haber monigotes fuera de la arena
	for wallCollision in $Walls.get_children():
		wallCollision.disabled = false
	
	for e in effects:
		e.create(self)
	
	die.prepareArrow = $PrepareArrow
	die.rolled.connect(startEffect)
	die.onCubilete.connect(func():
		%MultipleResCamera.showSlotMachine()
		if activeEffect != -1:
			effects[activeEffect].end())
	die.dropped.connect(%MultipleResCamera.returnToArena)
	
	BetHandler.startGame(self)
	
	%MultipleResCamera.startGameAnimation()

var winnerPos : Vector3
func resetArena():
	effects[activeEffect].end()
	activeEffect = -1
	
	$PrepareArrow.visible = false
	
	betting = true
	die.queue_free()
	
	%MultipleResCamera.zoomTo(winnerPos)
	await get_tree().create_timer(5).timeout
	
	for mon in monigotes:
		mon.queue_free()
	
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
	monigotesAlive -= 1
	
	monigotes.erase(mon)
	
	if monigotesAlive == 1:
		winnerPos = monigotes[0].position
		BetHandler.settleBet(monigotes[0].player.id)
		resetArena()
	if monigotesAlive == 0:
		winnerPos = mon.position
		BetHandler.settleBet(mon.player.id)
		resetArena()

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
