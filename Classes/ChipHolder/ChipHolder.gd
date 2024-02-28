extends Node3D
class_name ChipHolder

@export var chipPileScene : PackedScene

var piles : Dictionary
var waitingToStart := false
var gameEnded := false

var ownedMonigotes : Array[Monigote] = []

func _ready():
	var i := 0
	for player in PlayerHandler.getPlayersAlive():
		var playerPile = chipPileScene.instantiate()
		playerPile.isDisplay = true
		playerPile.playerIdDisplay = player.id
		playerPile.position = $PilePositions.get_children()[i].position
		playerPile.scale = Vector3.ONE * 1.3
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

func jumpMonigoteTo(monigote : Monigote, pos : Vector3) -> Tween:
	var height := 5.0
	var jumpCurve = Curve3D.new()
	jumpCurve.add_point(monigote.position)
	jumpCurve.add_point(pos, Vector3(0,height,0))

	var jumpTween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	jumpTween.tween_method(func (t):
		monigote.position = jumpCurve.sample(0, t),
		0.0, 1.0, .5)
	return jumpTween

func getPositionForMonigote(playerId : int) -> Vector3:
	var pos = piles[playerId].position
	pos.y = piles[playerId].y
	return pos

func ownMonigotes(arr : Array[Monigote]) -> void:
	for mon in arr:
		mon.set_physics_process(false)
		mon.set_process(false)
		mon.reparent(self)

		jumpMonigoteTo(mon, getPositionForMonigote(mon.player.id))\
				.tween_callback(func (): ownedMonigotes.append(mon))

func sendMonigotesToArena(arena : Arena):
	for m in ownedMonigotes:
		jumpMonigoteTo(m, Vector3(m.position.x, Globals.SPRITE_HEIGHT, 1))\
				.tween_callback(func ():
					m.set_process(true)
					m.set_physics_process(true))
		arena.recieveMonigote(m)
	ownedMonigotes.clear()

func createMonigotes():
	ownedMonigotes = PlayerHandler.instantiatePlayers()
	for mon in ownedMonigotes:
		add_child(mon)
		mon.set_process(false)
		mon.set_physics_process(false)

func _process(_delta):
	for mon in ownedMonigotes:
		mon.position = getPositionForMonigote(mon.player.id)

func startLeaderboardAnimation(winnerId):
	var timeBetweenSteps := 1.3
	var timeBetweenChips := .2

	createMonigotes()
	reset()
	BetHandler.settleBet(winnerId)

	gameEnded = BetHandler.round == BetHandler.roundAmount or PlayerHandler.getPlayersAlive().size() == 1
	if not gameEnded:
		$RoundNumber.text = "Round " + str(BetHandler.round) + "/" + str(BetHandler.roundAmount)
	else:
		$RoundNumber.text = "GAME ENDED"

	await get_tree().create_timer(1).timeout
	###################
	# Eliminar apuestas
	###################
	$LeaderboardTitleLabel.text = "Removing bets"
	
	var maxBet := 0 # Para calcular cuánto tarda la animación
	for player in PlayerHandler.getPlayersInOrder():
		var totalBets = player.getTotalBets()
		if totalBets == 0:
			continue
		maxBet = max(maxBet, totalBets)
		var chipRemover := get_tree().create_tween().set_loops(totalBets)
		chipRemover.tween_callback(removeChipFromPlayer.bind(player.id))
		chipRemover.tween_interval(timeBetweenChips)
	await get_tree().create_timer(maxBet * timeBetweenChips + timeBetweenSteps).timeout

	##############################
	# Agregar ganancias de apuesta
	##############################
	var betWinnersString := ""
	var winner_i := 0
	for winner in BetHandler.getCandidates().filter(BetHandler.hasWon):
		if winner_i != 0:
			betWinnersString += ", "
		betWinnersString += BetHandler.getCandidateName(winner)
		winner_i += 1

	$LeaderboardTitleLabel.text = "Bet result: " + betWinnersString
	var maxGain := 0
	for player in PlayerHandler.getPlayersInOrder():
		var winnings = BetHandler.getPlayerBetWinnings(player.id)
		if winnings == 0:
			continue
		maxGain = max(maxGain, winnings)
		var chipAdder := get_tree().create_tween().set_loops(winnings)
		chipAdder.tween_callback(addChipToPlayer.bind(player.id))
		chipAdder.tween_interval(timeBetweenChips)
	await get_tree().create_timer(maxGain * timeBetweenChips + timeBetweenSteps).timeout
	
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
	else:
		$LeaderboardTitleLabel.text = "Press 'grab' to restart game"

	waitingToStart = true

func _input(event):
	if not waitingToStart:
		return

	for player in PlayerHandler.getPlayersAlive():
		if event.is_action(Controllers.getActions(player.inputController)["grab"]):
			if gameEnded:
				PlayerHandler.resetAllPlayers()
				BetHandler.round = 0
				gameEnded = false

			get_parent().goToBettingScene()
			$RoundNumber.text = ""
			$LeaderboardTitleLabel.text = ""
			waitingToStart = false
