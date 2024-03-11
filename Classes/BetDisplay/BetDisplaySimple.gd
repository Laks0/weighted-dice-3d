extends Node3D
class_name BetDisplaySimple

signal gameStarted

@export var halfWidth : float = 7
@export var chipPileScene : PackedScene
@export var selectorScene : PackedScene
@export var selectorZ : float = -1.5
@export var selectorZHeight : float = .5

@export var playerPileZ : float = -8

@export var chipHolder : ChipHolder

var piles : Array
var candidatesOnLeft : int
var candidatesOnRight : int

var selectors : Dictionary
var selected : Dictionary
var betted : Dictionary
var isReady : Dictionary

#para SFX
var pointerShouldMove : bool

var betting = false

func startBetting():
	$StartDelay.start()
	# Resetear cualquier valor viejo
	chipHolder.reset()
	for pile in piles:
		pile.queue_free()
	piles = []
	selectors.clear()
	selected.clear()
	
	betting = true
	BetHandler.startRound()
	$Slotmachine/BetName.text = "Betting on:\n" + BetHandler.getBetName()
	
	var candidates := BetHandler.getCandidates()
	
	@warning_ignore("integer_division")
	candidatesOnLeft = candidates.size() / 2
	candidatesOnRight = candidates.size() - candidatesOnLeft
	
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
	
	
	_repositionSelectors()

func startArena():
	SfxHandler.playSound("displayReady")
	chipHolder.sendMonigotesToArena(get_parent())
	get_parent().startArena()
	betting = false
	for sel in selectors.values():
		sel.queue_free()
	gameStarted.emit()
	
	$Label3D2.visible = false

func _process(_delta):
	$AIBetController.set_process(betting)
	if (not betting) or (not $StartDelay.is_stopped()):
		return
	
	if isReady.keys().filter(func (id : int): return isReady[id]).size() == isReady.keys().size():
		startArena()
		return
	
	for player : PlayerHandler.Player in PlayerHandler.getPlayersAlive():
		## Interacción
		var playerActions = Controllers.getActions(player.inputController)

		# Movimientos
		if Input.is_action_just_pressed(playerActions["left"]) and not isReady[player.id]:
			if selected[player.id] != 0:
				SfxHandler.playSound("pointerMove")
			else: SfxHandler.playSound("pointerCantMove")
			if selected[player.id] == -1:
				selected[player.id] = candidatesOnLeft-1
			elif selected[player.id] == candidatesOnLeft:
				selected[player.id] = -1
			else:
				selected[player.id] = max(selected[player.id]-1, 0)

			_repositionSelectors()
		
		if Input.is_action_just_pressed(playerActions["right"]) and not isReady[player.id]:
			if selected[player.id] != piles.size()-1:
				SfxHandler.playSound("pointerMove")
			else: SfxHandler.playSound("pointerCantMove")
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
				if isReady[player.id]:
					SfxHandler.playSound("playerReady")
				else:
					SfxHandler.playSound("readyCancel") 
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
	SfxHandler.playSound("pointerSelect")

	if selected[player.id] == -1 or piles[selected[player.id]].candidate != candidate:
		selectCandidate(player.id, candidate)
	
	chipHolder.removeChipFromPlayer(player.id)
	player.increaseBet(candidate)
	betted[player.id] += 1
	piles[selected[player.id]].addChip(player.id)
	_repositionSelectors()

func decreaseCandidateBet(player : PlayerHandler.Player, candidate : int):
	if player.bets[candidate] == 0:
		return
	SfxHandler.playSound("pointerCancel")

	if selected[player.id] == -1 or piles[selected[player.id]].candidate != candidate:
		selectCandidate(player.id, candidate)
	
	chipHolder.addChipToPlayer(player.id)
	player.decreaseBet(candidate)
	betted[player.id] -= 1
	piles[selected[player.id]].removeChip(player.id)
	_repositionSelectors()

