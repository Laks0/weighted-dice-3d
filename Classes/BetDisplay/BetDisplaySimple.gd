extends Node3D
class_name BetDisplaySimple

signal allPlayersReady

@export var halfWidth : float = 7
@export var chipPileScene : PackedScene
@export var selectorScene : PackedScene
@export var selectorZ : float = -1.5
@export var selectorZHeight : float = .5
@export var horizontalSelectorSeparation : float = 1.7

@export var playerPileZ : float = -8
@export var candidateOddsZDisplacement : float = 1.42

@export var chipHolder : ChipHolder
@export var stageHandler : StageHandler

@export var betScreen2d : Node2D

@export var _candidateLabelScene : PackedScene

var piles : Array
var labels : Array
var candidatesOnLeft : int
var candidatesOnRight : int

var selectors : Dictionary
var selected : Dictionary
var betted : Dictionary
var isReady : Dictionary

func createLabelForCandidate(candidate) -> Label3D:
	var label : Label3D = _candidateLabelScene.instantiate()
	label.setCandidate(candidate)
	label.position.z = candidateOddsZDisplacement
	for pile in piles:
		if pile.candidate == candidate:
			pile.add_child(label)
			labels.append(label)
			break
	label.look_at(label.to_global(Vector3.DOWN), Vector3.FORWARD)
	return label

func startBetting():
	Narrator.playBank("bets")
	$StartDelay.start()
	# Resetear cualquier valor viejo
	chipHolder.reset()
	for pile in piles:
		pile.queue_free()
	piles = []
	for sel in selectors.values():
		if is_instance_valid(sel):
			sel.queue_free()
	selectors.clear()
	selected.clear()
	
	PlayerHandler.clearAllPlayersBets()
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
		
		createLabelForCandidate(candidates[i])
	
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
	
	$BetDescription.text = BetHandler.getBetDescription()
	$BetDescription.visible = true

func endBetting():
	SfxHandler.playSound("displayReady")
	for sel in selectors.values():
		sel.queue_free()
	labels.clear()
	$BetDescription.visible = false

@export var timeToHoldBet : float = .5
var holdTimers : PackedFloat32Array = [.0, .0, .0, .0, .0, .0]
var holdRemoveTimers : PackedFloat32Array = [.0, .0, .0, .0, .0, .0]

func _process(delta):
	if (stageHandler.currentStage != StageHandler.Stages.BETTING) or (not $StartDelay.is_stopped()):
		return
	
	if isReady.keys().filter(func (id : int): return isReady[id]).size() == isReady.keys().size():
		endBetting()
		allPlayersReady.emit()
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
			selector.get_node("NumberLabel").text = "OK" if isReady[player.id] else ""
			if Input.is_action_just_pressed(playerActions["ui_ok"]):
				isReady[player.id] = true
				SfxHandler.playSound("playerReady")
			if Input.is_action_just_pressed(playerActions["ui_cancel"]):
				isReady[player.id] = false
				SfxHandler.playSound("readyCancel")
			continue
		
		var selectedPile = piles[selected[player.id]]
		var candidate = selectedPile.candidate
		selector.get_node("NumberLabel").text = str(player.getAmountBettedOn(candidate))
		if not BetHandler.canBet(player.id, candidate):
			selector.get_node("NumberLabel").text = "X"
		
		# Bajar apuesta
		if Input.is_action_just_pressed(playerActions["up"]) or Input.is_action_just_pressed(playerActions["ui_cancel"]):
			decreaseCandidateBet(player, candidate)
		
		# Mantener para sacar apuesta
		if Input.is_action_pressed(playerActions["up"]) or Input.is_action_just_pressed(playerActions["ui_cancel"]):
			holdRemoveTimers[player.id] += delta
			if holdRemoveTimers[player.id] > timeToHoldBet:
				decreaseCandidateBet(player, candidate)
				holdRemoveTimers[player.id] = timeToHoldBet * .9
		if Input.is_action_just_released(playerActions["up"]) or Input.is_action_just_released(playerActions["ui_cancel"]):
			holdRemoveTimers[player.id] = 0.0
		
		# Subir apuesta
		if Input.is_action_just_pressed(playerActions["ui_ok"]) or Input.is_action_just_pressed(playerActions["down"]):
			increaseCandidateBet(player, candidate)
		
		# Mantener para apostar
		if Input.is_action_pressed(playerActions["ui_ok"]) or Input.is_action_pressed(playerActions["down"]):
			holdTimers[player.id] += delta
			if holdTimers[player.id] > timeToHoldBet:
				increaseCandidateBet(player, candidate)
				holdTimers[player.id] = timeToHoldBet * .9
		if Input.is_action_just_released(playerActions["ui_ok"]) or Input.is_action_just_released(playerActions["down"]):
			holdTimers[player.id] = 0.0

func _repositionSelectors() -> void:
	for i in range(-1, piles.size()):
		var pileSelectors : Array = selected.keys()\
			.filter(func (id : int): return selected[id] == i)\
			.map(func (id : int): return selectors[id])
		
		
		var spaceBetweenSelectorsBottom : float = horizontalSelectorSeparation/(min(3,pileSelectors.size())+1)
		var spaceBetweenSelectorsTop : float = horizontalSelectorSeparation/(max(0,pileSelectors.size()-3)+1)
		
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
			var newX = centerX - horizontalSelectorSeparation/2 + spaceBetweenSelectorsBottom * (l+1)
			if l >= 3:
				newZ -= selectorZHeight
				newX = centerX - horizontalSelectorSeparation/2 + spaceBetweenSelectorsTop * (l-2)
			
			var sel = pileSelectors[l]
			var positionTween = create_tween().set_ease(Tween.EASE_IN_OUT)
			positionTween.tween_property(sel, "position", Vector3(newX, centerY, newZ), .15)

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

@export var allInParticlesScene : PackedScene

func increaseCandidateBet(player : PlayerHandler.Player, candidate : int):
	if betted[player.id] >= player.bank or not BetHandler.canBet(player.id, candidate):
		shakeSelector(player.id)
		return
	SfxHandler.playSound("pointerSelect")

	if selected[player.id] == -1 or piles[selected[player.id]].candidate != candidate:
		selectCandidate(player.id, candidate)
	
	chipHolder.removeChipFromPlayer(player.id)
	player.increaseBet(candidate)
	betted[player.id] += 1
	piles[selected[player.id]].addChip(player.id)
	_repositionSelectors()
	
	# Efecto de all in
	if player.bank == player.getAmountBettedOn(candidate):
		var particles = allInParticlesScene.instantiate()
		particles.position = piles[selected[player.id]].position + Vector3(0, 1, .2)
		particles.playerId = player.id
		add_child(particles)

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

func shakeSelector(playerId : int):
	var sel : Node3D = selectors[playerId]
	var restPosition := sel.position.x
	var magnitude := .05
	var time := .1
	while time > 0:
		sel.position.x = restPosition + (randf() * 2 - 1) * magnitude
		await get_tree().process_frame
		time -= get_process_delta_time()
	
	_repositionSelectors()

func showBetNameCameraAnimation(currentCamera : MultipleResCamera) -> Signal:
	return currentCamera.goToCamera($ShowBetNameCamera).finished

func showBetDescriptionCameraAnimation(currentCamera : MultipleResCamera) -> Signal:
	return currentCamera.goToCamera($ShowBetDescriptionCamera).finished

func showBetNameAnimation(currentCamera : MultipleResCamera):
	await showBetNameCameraAnimation(currentCamera)
	await get_tree().create_timer(.7).timeout
	await betScreen2d.revealBetNameAnimation()
	await get_tree().create_timer(1.5).timeout
	$CloseupBetDescription.visible = true
	$CloseupBetDescription.text = BetHandler.getBetDescription()
	await showBetDescriptionCameraAnimation(currentCamera)
	#create_tween().tween_property($CloseupBetDescription, "position:y", $CloseupBetDescription.position.y, 1)\
	#	.from($CloseupBetDescription.position.y - 10)
	await get_tree().create_timer(3).timeout
	_startOddsAnimations()
	$CloseupBetDescription.visible = false

func _startOddsAnimations():
	var delayBetweenAnimations := .2
	for i in range(2, 6):
		var lastTween : Tween = null
		var delay := 0.0
		for l in labels:
			if l.odds == i:
				lastTween = l.startOddsAnimation(delay)
				delay += delayBetweenAnimations
		
		if lastTween != null:
			await lastTween.finished
			await get_tree().create_timer(delayBetweenAnimations).timeout
