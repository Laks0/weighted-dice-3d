extends VBoxContainer
class_name PlayerBetCard

var candidate = null

func setCandidate(c):
	candidate = c
	$NameLabel.text = BetHandler.getCandidateName(candidate)
	
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

func _process(_delta):
	if candidate == null:
		return
	
	if BetHandler.getScores().has(candidate):
		var isWinning = BetHandler.getCandidatesOnFirst().has(candidate)
		isWinning = isWinning or not BetHandler.betOngoing
		$Background.modulate.v = 1.0 if isWinning else .5
	
	for p in PlayerHandler.getPlayersAlive():
		%PlayerGrid.get_child(p.id).visible = p.getAmountBettedOn(candidate) > 0
		%GenericGrid.get_child(p.id).visible = p.getAmountBettedOn(candidate) > 0
