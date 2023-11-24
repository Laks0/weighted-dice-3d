extends Node3D
class_name Arena

@export var monigoteResource : PackedScene

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
	
	startEffect(5)

func _process(delta):
	gameTime += delta

	if activeEffect != -1:
		effects[activeEffect].update(delta)

func startEffect(n : int):
	if activeEffect != -1:
		effects[activeEffect].end()
	
	activeEffect = n
	effects[activeEffect].start()
	
	$HUD.effectStarted(effects[activeEffect].effectName)

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
	
	if monigotesAlive <= 1:
		endGame(monigotes[0].player.id)

func endGame(winnerId : int):
	BetHandler.settleBet(winnerId)
	
	get_tree().change_scene_to_file("res://Scenes/RoundEnd/RoundEnd.tscn")

func getMainLight() -> DirectionalLight3D:
	return $DirectionalLight3D
