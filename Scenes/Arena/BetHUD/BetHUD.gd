extends Control

signal reseted

@export var cardScene : PackedScene

func _ready():
	BetHandler.pickedNewBet.connect(onNewBetPicked)
	BetHandler.betStarted.connect(onBetStarted)

func onNewBetPicked():
	if BetHandler.round == 1:
		return
	
	if BetHandler.currentBet.betType == Bet.BetType.CUSTOM:
		%BetName.visible = false
	else:
		%BetName.visible = true
		%BetName.text = BetHandler.getBetName()
	
	var cards : Array[BetCard] = []
	for c in BetHandler.getCandidates():
		var card : BetCard = cardScene.instantiate()
		card.setCandidate(c)
		card.visible = false
		cards.append(card)
	
	@warning_ignore("integer_division")
	for i in range(cards.size()/2):
		$LeftContainer.add_child(cards[i])
	@warning_ignore("integer_division")
	for i in range(cards.size()/2, cards.size()):
		$RightContainer.add_child(cards[i])

func onBetStarted():
	pass

func showBetName():
	if BetHandler.round == 1:
		return
	
	visible = true
	
	var cards := $LeftContainer.get_children()
	cards.append_array($RightContainer.get_children())
	for i in range(cards.size()):
		cards[i].startIntroAnimation(.1*i)

func reset():
	reseted.emit()
	visible = false
	for c in $LeftContainer.get_children():
		c.queue_free()
	for c in $RightContainer.get_children():
		c.queue_free()
