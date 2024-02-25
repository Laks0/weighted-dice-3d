extends Node3D
class_name BetDisplaySimple

signal increaseBet(playerId, candidate)
signal decreaseBet(playerId, candidate)
signal gameStarted

@export var halfWidth : float = 7
@export var chipPileScene : PackedScene
@export var selectorScene : PackedScene
@export var selectorZ : float = -1.5
@export var selectorZHeight : float = .5

@export var playerPileZ : float = -8

var piles : Array
var candidatesOnLeft : int
var candidatesOnRight : int

var selectors : Dictionary
var selected : Dictionary
var betted : Dictionary
var isReady : Dictionary

var betting = true

func _ready():
	BetHandler.startRound()
	$Slotmachine/BetName.text = BetHandler.getBetName()
	
	var candidates := BetHandler.getCandidates()
	
	@warning_ignore("integer_division")
	candidatesOnLeft = candidates.size() / 2
	candidatesOnRight = candidates.size() - candidatesOnLeft
	
	var distanceBetweenPlayerPiles = halfWidth*2 / (PlayerHandler.getPlayersAlive().size()+1)
	
	for i in range(candidates.size()):
		var xPos : float
		var chipPile = chipPileScene.instantiate()
		
		var distanceBetweenLeft = halfWidth / (candidatesOnLeft + 1)
		var distanceBetweenRight = halfWidth / (candidatesOnRight + 1)
		
		if i < candidatesOnLeft:
			xPos = -halfWidth + (i+1) * distanceBetweenLeft
		else:
			xPos = (i-candidatesOnLeft+1) * distanceBetweenRight
		
		chipPile.position = Vector3(xPos,.15,-.6)
		chipPile.candidate = candidates[i]
		
		add_child(chipPile)
		piles.append(chipPile)
		
		increaseBet.connect(func (playerId, candidate):
			if candidate == chipPile.candidate:
				chipPile.addChip(playerId))
		decreaseBet.connect(func (playerId, candidate):
			if candidate == chipPile.candidate:
				chipPile.removeChip(playerId))
	
	for i in range(PlayerHandler.getPlayersAlive().size()):
		var player : PlayerHandler.Player = PlayerHandler.getPlayersAlive()[i]
		var sel = selectorScene.instantiate()
		selectors[player.id] = sel
		selected[player.id] = PlayerHandler.getPlayerIndex(player) % candidates.size()
		betted[player.id] = 0
		sel.get_node("NumberLabel").modulate = player.color
		sel.get_node("ArrowSprite").modulate = player.color
		sel.position = Vector3(0,1,selectorZ)
		add_child(sel)
		
		isReady[player.id] = false
		
		for candidate in candidates:
			player.setBet(0, candidate)
		
		# Pilas de las fichas de jugadores
		var playerPile = chipPileScene.instantiate()
		playerPile.isDisplay = true
		playerPile.playerIdDisplay = player.id
		increaseBet.connect(func (playerId, _candidate):
			if playerId == player.id:
				playerPile.removeChip(player.id))
		
		decreaseBet.connect(func (playerId, _candidate):
			if playerId == player.id:
				playerPile.addChip(player.id))
		
		gameStarted.connect(func ():
			var exitTween := create_tween()
			exitTween.tween_property(playerPile, "position:x", 10, .1).as_relative()
			exitTween.tween_callback(playerPile.queue_free))
		
		playerPile.position = Vector3(-halfWidth + (i+1)*distanceBetweenPlayerPiles,1,playerPileZ)
		add_child(playerPile)
		
		for _i in player.bank:
			playerPile.addChip(player.id)
	
	$Slotmachine.set_process(false)
	_repositionSelectors()

func _process(_delta):
	if not betting:
		return
	
	if isReady.keys().filter(func (id : int): return isReady[id]).size() == isReady.keys().size():
		get_parent().startArena()
		betting = false
		$Slotmachine.set_process(true)
		for sel in selectors.values():
			sel.queue_free()
		gameStarted.emit()
		return
	
	for player : PlayerHandler.Player in PlayerHandler.getPlayersAlive():
		## Interacción
		var playerActions = Controllers.getActions(player.inputController)

		# Movimientos
		if Input.is_action_just_pressed(playerActions["left"]) and not isReady[player.id]:
			if selected[player.id] == -1:
				selected[player.id] = candidatesOnLeft-1
			elif selected[player.id] == candidatesOnLeft:
				selected[player.id] = -1
			else:
				selected[player.id] = max(selected[player.id]-1, 0)
			_repositionSelectors()
		
		if Input.is_action_just_pressed(playerActions["right"]) and not isReady[player.id]:
			if selected[player.id] == -1:
				selected[player.id] = candidatesOnLeft
			elif selected[player.id] == candidatesOnLeft-1:
				selected[player.id] = -1
			else:
				selected[player.id] = min(selected[player.id]+1, piles.size()-1)
			_repositionSelectors()
		
		var selector = selectors[player.id]
		
		# Ready
		if selected[player.id] == -1:
			selector.get_node("NumberLabel").text = "X" if isReady[player.id] else ""
			if Input.is_action_just_pressed(playerActions["grab"]):
				isReady[player.id] = not isReady[player.id]
			
			continue
		
		var selectedPile = piles[selected[player.id]]
		var candidate = selectedPile.candidate
		selector.get_node("NumberLabel").text = str(player.getAmountBettedOn(candidate))
		
		# Bajar apuesta
		if Input.is_action_just_pressed(playerActions["up"]):
			decreaseCandidateBet(player, candidate)
		
		# Subir apuesta
		if Input.is_action_just_pressed(playerActions["grab"]) or Input.is_action_just_pressed(playerActions["down"]):
			increaseCandidateBet(player, candidate)

func _repositionSelectors() -> void:
	for i in range(-1, piles.size()):
		var pileSelectors : Array = selected.keys()\
			.filter(func (id : int): return selected[id] == i)\
			.map(func (id : int): return selectors[id])
		
		var selectorSpaceWidth : float = 1.4
		
		var spaceBetweenSelectorsBottom : float = selectorSpaceWidth/(min(3,pileSelectors.size())+1)
		var spaceBetweenSelectorsTop : float = selectorSpaceWidth/(max(0,pileSelectors.size()-3)+1)
		
		var centerX
		var centerY
		if i == -1:
			centerX = 0
			centerY = 2
		else:
			centerX = piles[i].position.x
			centerY = max(1, piles[i].y + piles[i].position.y)
		
		for l in range(pileSelectors.size()):
			var newZ := selectorZ
			var newX = centerX - selectorSpaceWidth/2 + spaceBetweenSelectorsBottom * (l+1)
			if l >= 3:
				newZ -= selectorZHeight
				newX = centerX - selectorSpaceWidth/2 + spaceBetweenSelectorsTop * (l-2)
			
			var sel = pileSelectors[l]
			var positionTween = create_tween().set_ease(Tween.EASE_IN_OUT)
			positionTween.tween_property(sel, "position", Vector3(newX, centerY, newZ), .15)

## FUNCIONES DE API PARA LA IA ##

func selectCandidate(playerId : int, candidate : int):
	var index = 0
	for i in range(piles.size()):
		if piles[i].candidate == candidate:
			index = i
			break
	
	selected[playerId] = index
	_repositionSelectors()

func playerReady(playerId : int) -> void:
	if selected[playerId] != -1:
		selected[playerId] = -1
		_repositionSelectors()
	isReady[playerId] = true

func increaseCandidateBet(player : PlayerHandler.Player, candidate : int):
	if betted[player.id] >= player.bank or not BetHandler.canBet(player.id, candidate):
		return

	if selected[player.id] == -1 or piles[selected[player.id]].candidate != candidate:
		selectCandidate(player.id, candidate)
	
	player.increaseBet(candidate)
	betted[player.id] += 1
	emit_signal("increaseBet", player.id, candidate)
	_repositionSelectors()

func decreaseCandidateBet(player : PlayerHandler.Player, candidate : int):
	if player.bank - betted[player.id] <= 0:
		return

	if selected[player.id] == -1 or piles[selected[player.id]].candidate != candidate:
		selectCandidate(player.id, candidate)

	player.decreaseBet(candidate)
	betted[player.id] -= 1
	emit_signal("decreaseBet", player.id, candidate)
	_repositionSelectors()

