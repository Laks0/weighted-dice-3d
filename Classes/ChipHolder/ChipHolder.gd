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

## La diferencia entre la base de una pila y la posición en donde tiene que ir la ficha de bonus
@export var positionDifferenceForBonusChip := Vector3(.5, .33, .5)
@export var bonusChipScene : PackedScene

func getPilePosition(i : int) -> Vector3:
	return $PilePositions.get_children()[i].position

func _ready():
	var i := 0
	for player in PlayerHandler.getPlayersAlive():
		var playerPile = chipPileScene.instantiate()
		playerPile.isDisplay = true
		playerPile.playerIdDisplay = player.id
		playerPile.position = getPilePosition(i)
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

func getPlayerMonigote(playerId : int) -> Monigote:
	for m : Monigote in ownedMonigotes:
		if m.player.id == playerId:
			return m
	return null

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
	
	## APARICIÓN FICHAS DE BONUS
	var bonusChip : Node3D
	for p : PlayerHandler.Player in PlayerHandler.getPlayersAlive():
		if p.roundBonus == 0:
			continue
		
		bonusChip = bonusChipScene.instantiate()
		bonusChip.bonus = p.roundBonus
		bonusChip.rotation.x = PI/2
		bonusChip.position = piles[p.id].position + positionDifferenceForBonusChip
		add_child(bonusChip)
		bonusChip.disable()
		bonusChip.create_tween().tween_property(bonusChip, "position:y", bonusChip.position.y, 1).from(5)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_ELASTIC)
		
		nextRound.connect(bonusChip.queue_free)
	
	setSkyRotationStrength(defaultSkyRotation*2)

	gameEnded = BetHandler.round == BetHandler.roundAmount or PlayerHandler.getPlayersAlive().size() == 1
	
	if not gameEnded:
		$RoundNumber.modulate = Color.WHITE
		$RoundNumber.text = "Ronda " + str(BetHandler.round) + " de " + str(BetHandler.roundAmount)
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
	
	$BetResultsLabel.text = BetHandler.getWinnersText()
	
	await changeAllPlayerChips(BetHandler.getPlayerBetWinnings, timeBetweenChips).finished
	await get_tree().create_timer(timeBetweenSteps).timeout 
	
	#################################
	# Agregar premio de sobreviviente
	#################################
	var survivor : PlayerHandler.Player = PlayerHandler.getPlayerById(winnerId)
	$SurvivorLabel.modulate = survivor.color
	$SurvivorLabel.text = "Último sobreviviente: %s" % survivor.name
	
	for _i in range(BetHandler.getRoundPrize()):
		addChipToPlayer(winnerId)
		await get_tree().create_timer(timeBetweenChips).timeout
	
	await get_tree().create_timer(timeBetweenSteps).timeout
	
	#################
	# Bonus de fichas
	#################
	
	if is_instance_valid(bonusChip):
		await bonusChip.create_tween().tween_property(bonusChip, "position:y", -5, .3)\
				.set_ease(Tween.EASE_IN)\
				.set_trans(Tween.TRANS_SPRING).finished
		
		bonusChip.queue_free()
	
	await changeAllPlayerChips(func (id : int): 
		return PlayerHandler.getPlayerById(id).roundBonus, 
		timeBetweenChips).finished
	
	##############################
	# Eliminar a los que perdieron
	##############################
	
	var monFallTime := .7
	var someoneLost := false
	for mon : Monigote in ownedMonigotes:
		if mon.player.bank > 0:
			continue
		
		someoneLost = true
		
		mon.dance()
		
		disownMonigote(mon)
		
		mon.create_tween().tween_property(mon, "position:y", -4, monFallTime)\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_CIRC)
	
	if someoneLost:
		$MonigoteFall.play()
		create_tween().tween_property($MonigoteFall, "pitch_scale", .91, monFallTime)
		await get_tree().create_timer(monFallTime).timeout
	
	###########################
	# Animación de fin de juego
	###########################
	
	# Fin de la animación normal y esperar a que alguien presione grab
	if not gameEnded:
		waitingToStart = true
		return
	
	var winners : Array[PlayerHandler.Player] = PlayerHandler.getWinningPlayers()
	if winners.size() != 1:
		$EndgameButtons.get_children()[0].focused = true
		gameEnded = true
		return
	
	var winner := winners[0]
	
	goToSkyColor(winner.color)
	getPlayerMonigote(winner.id).dance()
	
	await camera.zoomTo(getPositionForMonigote(winner.id)).finished
	
	# Fade in texto de ganador
	$WinnerLabel.text = "¡GANÓ %s!" % winner.name
	$WinnerLabel.visible = true
	create_tween().tween_property($WinnerLabel, "modulate:a", 1, .2).from(0)
	
	# Un tiempito para que baile el monigote
	await get_tree().create_timer(1).timeout
	
	for b : GamepadSelectButton in $EndgameButtons.get_children():
		b.controller = winner.inputController 
		b.visible = true
	$EndgameButtons.get_children()[0].focused = true
	gameEnded = true

func goToSkyColor(color : Color, alpha := .5, time := .5, instant := false):
	if instant:
		skyMaterial.set_shader_parameter("sky_color", color*alpha)
		return
	
	create_tween().tween_method(func(c : Color):
		skyMaterial.set_shader_parameter("sky_color", c)
	,skyMaterial.get_shader_parameter("sky_color"), color*alpha, time)

func setSkyRotationStrength(strength : float, time := .2, instant := false):
	if instant:
		skyMaterial.set_shader_parameter("rotation_strength", strength)
		return
	
	create_tween().tween_method(func(s : float):
		skyMaterial.set_shader_parameter("rotation_strength", s)
	,skyMaterial.get_shader_parameter("rotation_strength"), strength, time)

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
		$WinnerLabel.visible = false
		
		for b : GamepadSelectButton in $EndgameButtons.get_children():
			b.visible = false
			b.focused = false
	
	nextRound.emit()
	$RoundNumber.text = ""
	$BetResultsLabel.text = ""
	$SurvivorLabel.text = ""
	waitingToStart = false
	setSkyRotationStrength(defaultSkyRotation)

func _on_reselect_characters_pressed():
	skyMaterial.set_shader_parameter("speed", 1)
	goToSkyColor(defaultSkyColor, 1, 0, true)
	setSkyRotationStrength(defaultSkyRotation, 0, true)
	PlayerHandler.deleteAllPlayers()
	get_tree().change_scene_to_file("res://Scenes/CharacterScreen/CharacterScreen.tscn")
