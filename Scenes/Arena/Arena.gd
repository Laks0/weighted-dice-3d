extends Node3D
class_name Arena

signal effectStarted(effect)
signal gameEnded(winner) # winner : Monigote

@onready var effects : Array = $Effects.get_children()

const WIDTH = 11
const HEIGHT = 6

# Active effect va de 0 a 5
var activeEffect   : int = -1
var monigotesAlive : int = 0

var gameTime : float = 0

var monigotes : Array[Monigote]

var firstToDie : int = -1

func _ready():
	monigotes = PlayerHandler.instantiatePlayers(self)
	monigotesAlive = len(monigotes)
	
	for m in monigotes:
		m.died.connect(onMonigoteDeath.bind(m))
	
	for e in effects:
		e.create(self)
	
	%Die.prepareArrow = $PrepareArrow
	%Die.rolled.connect(startEffect)
	
	BetHandler.startGame(self)

func _process(delta):
	gameTime += delta

	if activeEffect != -1:
		effects[activeEffect].update(delta)

func startEffect(n : int):
	if activeEffect != -1:
		effects[activeEffect].end()
	
	activeEffect = n
	effects[activeEffect].start()
	
	emit_signal("effectStarted", effects[activeEffect])

# Esta función queda Legacy pero sigue teniendo sentido como un getter
func getLivingMonigotes() -> Array[Monigote]:
	return monigotes

func getRandomMonigote() -> Monigote:
	return monigotes[randi() % len(monigotes)]

func onMonigoteDeath(mon : Monigote):
	monigotesAlive -= 1
	
	if firstToDie == -1:
		firstToDie = mon.player.id
	
	monigotes.erase(mon)
	
	if monigotesAlive == 1:
		emit_signal("gameEnded", monigotes[0])
	if monigotesAlive == 0:
		emit_signal("gameEnded", mon)

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
