extends Node3D

@export var monigoteResource : PackedScene

@onready var effects : Array

# Active effect va de 0 a 5
var activeEffect   : int = -1
var monigotesAlive : int = 0

var gameTime : float = 0

func _ready():
	for player in PlayerHandler.players:
		if !player.isStillPlaying():
			continue
		
		var monigote := monigoteResource.instantiate() as Monigote
		
		monigote.player   = player
		monigote.position = Vector3((monigotesAlive+1) -5, 0, -1)
		
		monigotesAlive += 1
		add_child(monigote)

func _process(delta):
	gameTime += delta
	BetHandler.gameTime = gameTime

	if activeEffect != -1:
		effects[activeEffect].update(delta)

func startEffect(n : int):
	if activeEffect != -1:
		effects[activeEffect].end()

	activeEffect = n - 1
	effects[activeEffect].start()

func onMonigoteDeath():
	monigotesAlive -= 1
	if monigotesAlive <= 1:
		await get_tree().create_timer(0.1).timeout
		endGame()

func endGame():
	var lastStanding : Monigote = get_tree().get_nodes_in_group("Monigote")[0]
	BetHandler.lastEffect = activeEffect + 1
	BetHandler.settleBet(lastStanding.player.id)
	
	get_tree().change_scene_to_file("res://Escenas/BettingScreen/BettingScreen.tscn")

