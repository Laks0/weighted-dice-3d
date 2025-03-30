extends VBoxContainer
class_name BetCard

@export var winningAnimationLength : float = .5
@export var winningAnimationDisplacement : float = -100

var candidate = null
var isWinning : bool = false

func setCandidate(c):
	candidate = c
	%NameLabel.text = BetHandler.getCandidateName(candidate)
	
	# 6 es la carta genérica
	var atlasPosition : int
	if BetHandler.areCandidatesPlayers():
		atlasPosition = candidate
		%PlayerGrid.visible = true
	else:
		atlasPosition = 6
		$Background.self_modulate = BetHandler.getCandidateColor(candidate)
		%GenericGrid.visible = true
	$Background.texture.region.position.x = atlasPosition * $Background.texture.region.size.x
	
	if BetHandler.isCandidateWinning(candidate):
		isWinning = true

func _process(_delta):
	if candidate == null:
		return
	
	$Background.modulate.v = 1.0 if isWinning else .5
	
	for p in PlayerHandler.getPlayersAlive():
		%PlayerGrid.get_child(p.id).visible = p.getAmountBettedOn(candidate) > 0
		%GenericGrid.get_child(p.id).visible = p.getAmountBettedOn(candidate) > 0
	
	if BetHandler.currentBet.usesScore():
		%ScoreLabel.visible = true
		%ScoreLabel.text = BetHandler.getScoreText(candidate)
	else:
		%ScoreLabel.visible = false
	
	if BetHandler.isCandidateWinning(candidate) and not isWinning:
		isWinning = true
		startWinningAnimation()
	if isWinning and not BetHandler.isCandidateWinning(candidate):
		isWinning = false

func startWinningAnimation():
	if not BetHandler.currentBet is GameTimeBet:
		$BetCardWinningSfx.play()
	
	var positionTween := create_tween()
	positionTween.tween_property(self, "position:y", winningAnimationDisplacement, winningAnimationLength/2)\
		.as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	positionTween.tween_property(self, "position:y", 0, winningAnimationLength/2)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	var rotations := 4.0
	var rotationLength := winningAnimationLength / (rotations + 1)
	var rotationAngle := PI/8
	
	var rotationTween := create_tween()
	for i in range(rotations):
		var angleSign = 1 if i % 2 == 0 else -1
		rotationTween.tween_property(self, "rotation", angleSign * rotationAngle, rotationLength)
	rotationTween.tween_property(self, "rotation", 0, rotationLength)

func startIntroAnimation(delaySeconds : float) -> void:
	var positionTween = create_tween()
	positionTween.tween_method(func (_i): position.y = size.y + 30, 0,1, delaySeconds)
	positionTween.tween_property(self, "position:y", 0, .2).from(size.y + 30)
	
	get_tree().process_frame.connect(func(): visible = true)
