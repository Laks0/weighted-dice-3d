extends Node2D

func _ready():
	BetHandler.pickedNewBet.connect(betChanged)

func _process(_delta):
	if BetHandler.currentBet == null:
		return
	
	%ColorRect.color = Color.WHITE
	
	if not BetHandler.betOngoing:
		return
	return
	@warning_ignore("unreachable_code")
	if not (BetHandler.currentBet is FirstToDieBet or BetHandler.currentBet is SecondToDieBet):
		var firstCandidate = BetHandler.getCandidatesOnFirst()[0]
		%ColorRect.color = BetHandler.getCandidateColor(firstCandidate)

func betChanged():
	$ReferenceRect/BetName.text = BetHandler.getBetName()
	%BetName.visible = false
	%PresentationLabel.position = Vector2.ZERO

func revealBetNameAnimation() -> Signal:
	var tween := create_tween()
	%BetName.position.x = 1300
	%BetName.visible = true
	tween.tween_interval(1)
	tween.tween_property(%PresentationLabel, "position:x", -1000, 1)
	tween.parallel().tween_property(%BetName, "position:x", 0, 1)
	return tween.finished
