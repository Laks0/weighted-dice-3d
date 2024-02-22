extends Node3D

@export var halfWidth : float = 7
@export var chipPileScene : PackedScene
@export var selectorScene : PackedScene
@export var selectorZ : float = -1.5

var piles : Array
var candidatesOnLeft : int
var candidatesOnRight : int

var selectors : Dictionary
var selected : Dictionary
var betted : Dictionary

func _ready():
	BetHandler.startRound()
	
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
	
	for player : PlayerHandler.Player in PlayerHandler.getPlayersAlive():
		var sel = selectorScene.instantiate()
		selectors[player.id] = sel
		selected[player.id] = player.id % candidates.size()
		betted[player.id] = 0
		sel.get_node("NumberLabel").modulate = player.color
		sel.get_node("ArrowSprite").modulate = player.color
		sel.position = Vector3(0,1,selectorZ)
		add_child(sel)
		
		for candidate in candidates:
			player.setBet(0, candidate)
	
	$Slotmachine.set_process(false)
	_repositionSelectors()

func _process(_delta):
	for player : PlayerHandler.Player in PlayerHandler.getPlayersAlive():
		var selectedPile = piles[selected[player.id]]
		var candidate = selectedPile.candidate
		var selector = selectors[player.id]
		
		selector.get_node("NumberLabel").text = str(player.getAmountBettedOn(candidate))
		
		## Interacción
		var playerActions = Controllers.getActions(player.inputController)
		if Input.is_action_just_pressed(playerActions["left"]):
			selected[player.id] = max(selected[player.id]-1, 0)
			_repositionSelectors()
		
		if Input.is_action_just_pressed(playerActions["right"]):
			selected[player.id] = min(selected[player.id]+1, piles.size()-1)
			_repositionSelectors()
		
		if Input.is_action_just_pressed(playerActions["cancel"]) \
			and player.getAmountBettedOn(candidate) > 0:
			player.decreaseBet(candidate)
			selectedPile.removeChip(player.id)
			betted[player.id] -= 1
			_repositionSelectors()
		
		if betted[player.id] >= player.bank or not BetHandler.canBet(player.id, candidate):
			continue
		
		if Input.is_action_just_pressed(playerActions["grab"]):
			player.increaseBet(candidate)
			selectedPile.addChip(player.id)
			betted[player.id] += 1
			_repositionSelectors()

func _repositionSelectors() -> void:
	for i in range(piles.size()):
		var pileX = piles[i].position.x
		
		var pileSelectors : Array = selected.keys()\
			.filter(func (id : int): return selected[id] == i)\
			.map(func (id : int): return selectors[id])
		
		var selectorSpaceWidth : float = 1
		
		var spaceBetweenSelectors : float = selectorSpaceWidth/(pileSelectors.size()+2)
		
		for l in range(pileSelectors.size()):
			var sel = pileSelectors[l]
			var newX = pileX - selectorSpaceWidth/2 + spaceBetweenSelectors * (l+1)
			var positionTween = create_tween().set_ease(Tween.EASE_IN_OUT)
			positionTween.tween_property(sel, "position:x", newX, .15)
			positionTween.parallel().tween_property(sel, "position:y", max(1, piles[i].y + piles[i].position.y), .15)
