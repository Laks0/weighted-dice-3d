extends Control

signal reseted

@export var playerCardScene : PackedScene

func _ready():
	BetHandler.pickedNewBet.connect(onNewBetPicked)

func onNewBetPicked():
	if BetHandler.round == 1:
		return
	
	visible = true
	
	if BetHandler.currentBet.betType == Bet.BetType.CUSTOM:
		%BetName.visible = false
		return
	
	%BetName.visible = true
	%BetName.text = BetHandler.getBetName()
	
	var cards : Array[PlayerBetCard] = []
	for c in BetHandler.getCandidates():
		var card : PlayerBetCard = playerCardScene.instantiate()
		card.setPlayer(c)
		cards.append(card)
	
	@warning_ignore("integer_division")
	for i in range(cards.size()/2):
		$LeftContainer.add_child(cards[i])
	@warning_ignore("integer_division")
	for i in range(cards.size()/2, cards.size()):
		$RightContainer.add_child(cards[i])

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
