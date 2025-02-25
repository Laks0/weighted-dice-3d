extends Control

signal reseted

@export var cardScene : PackedScene

func _ready():
	BetHandler.pickedNewBet.connect(onNewBetPicked)
	BetHandler.betStarted.connect(onBetStarted)

func onNewBetPicked():
	if BetHandler.round == 1:
		return
	
	visible = true
	
	if BetHandler.currentBet.betType == Bet.BetType.CUSTOM:
		%BetName.visible = false
		# Si no es de jugadores, no se presta tanto a la confusión y las cartas
		# pueden aparecer en la arena
		$LeftContainer.visible = false
		$RightContainer.visible = false
	else:
		%BetName.visible = true
		%BetName.text = BetHandler.getBetName()
	
	var cards : Array[BetCard] = []
	for c in BetHandler.getCandidates():
		var card : BetCard = cardScene.instantiate()
		card.setCandidate(c)
		cards.append(card)
	
	@warning_ignore("integer_division")
	for i in range(cards.size()/2):
		$LeftContainer.add_child(cards[i])
	@warning_ignore("integer_division")
	for i in range(cards.size()/2, cards.size()):
		$RightContainer.add_child(cards[i])

func onBetStarted():
	$LeftContainer.visible = true
	$RightContainer.visible = true

func showBetName():
	$BetDisplay.visible = true

func reset():
	reseted.emit()
	visible = false
	$BetDisplay.visible = false
	for c in $LeftContainer.get_children():
		c.queue_free()
	for c in $RightContainer.get_children():
		c.queue_free()
