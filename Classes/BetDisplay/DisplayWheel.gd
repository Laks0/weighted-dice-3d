extends Node3D

var numberShown: float = 0

func _process(_delta):
	var firstCandidate = BetHandler.getCandidatesInOrder()[0]
	var firstScore: float = BetHandler.getScores()[firstCandidate]

	if BetHandler.currentBet is GameTimeBet:
		numberShown = BetHandler.currentBet.gameTime
	else:
		numberShown = firstScore
	
	$ScreenLight.light_color = BetHandler.getCandidateColor(firstCandidate)
	$TragaMonedas_002.get_surface_override_material(3).albedo_color = BetHandler.getCandidateColor(firstCandidate)

	$SlotWheel_0.rotateTo(floori(numberShown/100))
	$SlotWheel_1.rotateTo(floori(numberShown/10))
	$SlotWheel_2.rotateTo(floori(numberShown) % 10)
