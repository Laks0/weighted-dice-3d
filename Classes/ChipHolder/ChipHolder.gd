extends Node3D
class_name ChipHolder

signal resetRequest # Se pidió reiniciar el juego
signal nextRound # Se avanzó de ronda

@export var chipPileScene : PackedScene

var piles : Dictionary
var waitingToStart := false
var gameEnded := false

var ownedMonigotes : Array[Monigote] = []

@export var camera : MultipleResCamera
@export var worldEnvironment : WorldEnvironment
@onready var skyMaterial :ShaderMaterial= worldEnvironment.environment.sky.sky_material

@onready var defaultSkyColor : Color = skyMaterial.get_shader_parameter("sky_color")
@onready var defaultSkyRotation : float = skyMaterial.get_shader_parameter("rotation_strength")

func _ready():
	var i := 0
	for player in PlayerHandler.getPlayersAlive():
		var playerPile = chipPileScene.instantiate()
		playerPile.isDisplay = true
		playerPile.playerIdDisplay = player.id
		playerPile.position = $PilePositions.get_children()[i].position
		playerPile.scale = Vector3.ONE * 1.3
		playerPile.setLabelVisibility(false)
		add_child(playerPile)
		
		piles[player.id] = playerPile
		
		i += 1
	reset()

func addChipToPlayer(id : int) -> void:
	piles[id].addChip(id)

func removeChipFromPlayer(id : int) -> void:
	piles[id].removeChip(id)

func reset():
	for pile in piles.values():
		pile.displayBank()

func getPositionForMonigote(playerId : int) -> Vector3:
	var pos = piles[playerId].position
	pos.y = piles[playerId].y
	return to_global(pos)

func ownMonigote(mon : Monigote) -> void:
	if ownedMonigotes.has(mon):
		return
	
	mon.set_process(false)
	mon.set_physics_process(false)
	ownedMonigotes.append(mon)

func disownAllMonigotes() -> void:
	ownedMonigotes.clear()

func disownMonigote(mon : Monigote) -> void:
	ownedMonigotes.erase(mon)

func _process(_delta):
	for mon in ownedMonigotes:
		mon.position = getPositionForMonigote(mon.player.id)
	
	# Si tiene monigotes, muestra los valores de las fichas. No es lo más elegante pero anda
	if ownedMonigotes.size() == PlayerHandler.getPlayersAlive().size():
		for pile in piles.values():
			pile.setLabelVisibility(true)

func startLeaderboardAnimation(winnerId):
	var timeBetweenSteps := 1.3
	var timeBetweenChips := .2
	var skySpeed := 4.

	reset()
	BetHandler.settleBet(winnerId)
	
	setSkyRotationStrength(defaultSkyRotation*2)

	gameEnded = BetHandler.round == BetHandler.roundAmount or PlayerHandler.getPlayersAlive().size() == 1
	
	if not gameEnded:
		$RoundNumber.modulate = Color.WHITE
		$RoundNumber.text = "Round " + str(BetHandler.round) + "/" + str(BetHandler.roundAmount)
	else:
		$RoundNumber.text = "GAME OVER"
		$RoundNumber.modulate = Color.RED
		
		skyMaterial.set_shader_parameter("speed", skySpeed)

	await get_tree().create_timer(1).timeout
	###################
	# Eliminar apuestas
	###################
	await changeAllPlayerChips(func (playerId : int):
			return -PlayerHandler.getPlayerById(playerId).getTotalBets(), 
		timeBetweenChips
	).finished
	await get_tree().create_timer(timeBetweenSteps).timeout

	##############################
	# Agregar ganancias de apuesta
	##############################
	var betWinnersString := ""
	var winner_i := 0
	for winner in BetHandler.getWinnerCandidates():
		if winner_i != 0:
			betWinnersString += ", "
		betWinnersString += BetHandler.getCandidateName(winner)
		winner_i += 1

	$LeaderboardTitleLabel.text = "Bet result: " + betWinnersString
	
	await changeAllPlayerChips(BetHandler.getPlayerBetWinnings, timeBetweenChips).finished
	await get_tree().create_timer(timeBetweenSteps).timeout 
	
	#################################
	# Agregar premio de sobreviviente
	#################################
	$LeaderboardTitleLabel.text = "Last standing: " + PlayerHandler.getPlayerById(winnerId).name
	for _i in range(BetHandler.getRoundPrize()):
		addChipToPlayer(winnerId)
		await get_tree().create_timer(timeBetweenChips).timeout

	await get_tree().create_timer(timeBetweenSteps).timeout

	if not gameEnded:
		$LeaderboardTitleLabel.text = "Press 'grab' to continue"
		waitingToStart = true
		return
	
	###########################
	# Animación de fin de juego
	###########################
	
	var winners : Array[PlayerHandler.Player] = PlayerHandler.getWinningPlayers()
	if winners.size() != 1:
		return
	
	var winner := winners[0]
	
	goToSkyColor(winner.color)
	await camera.zoomTo(getPositionForMonigote(winner.id)).finished
	
	for b : GamepadSelectButton in $EndgameButtons.get_children():
		b.controller = winner.inputController 
		b.visible = true
	$EndgameButtons.get_children()[0].focused = true
	gameEnded = true

func goToSkyColor(color : Color, alpha : float = .5):
	create_tween().tween_method(func(c : Color):
		skyMaterial.set_shader_parameter("sky_color", c)
	,skyMaterial.get_shader_parameter("sky_color"), color*alpha, .5)

func setSkyRotationStrength(strength : float):
	create_tween().tween_method(func(s : float):
		skyMaterial.set_shader_parameter("rotation_strength", s)
	,skyMaterial.get_shader_parameter("rotation_strength"), strength, .2)

## Agrega a todos los jugadores una cantidad de fichas decidida por llamar amountGetter en su id
## retorna el tween que agrega las fichas
func changeAllPlayerChips(amountGetter : Callable, initialIntervalTime : float) -> Tween:
	var maxAmount := 0
	var maxTween : Tween
	for player in PlayerHandler.getPlayersInOrder():
		var amount : int = amountGetter.call(player.id)
		var changeFunction := addChipToPlayer if amount > 0 else removeChipFromPlayer
		var intervalTime := initialIntervalTime
		var changeTween := create_tween()
		# Para que emita finished aunque no tenga nada que hacer
		changeTween.tween_interval(.01)
		
		if abs(amount) >= maxAmount:
			maxAmount = abs(amount)
			maxTween = changeTween
		
		for i in range(abs(amount)):
			changeTween.tween_callback(changeFunction.bind(player.id))
			changeTween.tween_interval(intervalTime)
			
			intervalTime = max(.01, intervalTime - .005)
	
	return maxTween

func _input(event):
	if not waitingToStart:
		return

	for player in PlayerHandler.getPlayersAlive():
		if event.is_action(Controllers.getActions(player.inputController)["grab"]):
			goToNextRound()

## TODO: Esta lógica no se puede quedar acá, habría que mover todo lo posible a StageHandler
func goToNextRound() -> void:
	if gameEnded:
		resetRequest.emit()
		skyMaterial.set_shader_parameter("speed", 1)
		goToSkyColor(defaultSkyColor, 1)
		gameEnded = false
		
		for b : GamepadSelectButton in $EndgameButtons.get_children():
			b.visible = false
			b.focused = false
	
	nextRound.emit()
	$RoundNumber.text = ""
	$LeaderboardTitleLabel.text = ""
	waitingToStart = false
	setSkyRotationStrength(defaultSkyRotation)

func _on_reselect_characters_pressed():
	skyMaterial.set_shader_parameter("speed", 1)
	goToSkyColor(defaultSkyColor, 1)
	setSkyRotationStrength(defaultSkyRotation)
	PlayerHandler.deleteAllPlayers()
	get_tree().change_scene_to_file("res://Scenes/CharacterScreen/CharacterScreen.tscn")
