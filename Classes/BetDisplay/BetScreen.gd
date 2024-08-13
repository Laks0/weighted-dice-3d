extends Node2D

func _ready():
	BetHandler.pickedNewBet.connect(betChanged)

func _process(_delta):
	if BetHandler.currentBet == null:
		return
	
	%ColorRect.color = Color.WHITE
	
	if not BetHandler.betOngoing:
		return
	
	if not (BetHandler.currentBet is FirstToDieBet or BetHandler.currentBet is SecondToDieBet):
		var firstCandidate = BetHandler.getCandidatesInOrder()[0]
		%ColorRect.color = BetHandler.getCandidateColor(firstCandidate)

func betChanged():
	$ReferenceRect/BetName.text = BetHandler.getBetName()
