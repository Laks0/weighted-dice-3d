extends Node3D

var numberShown : float = 0

func _process(_delta):
	$Pantalla.get_surface_override_material(0).set_shader_parameter("screenTexture", $ScreenViewport.get_texture())
	
	$ScreenLight.light_color = Color.WHITE
	
	if not BetHandler.betOngoing:
		return
	
	return
	
	@warning_ignore("unreachable_code")
	var firstCandidate = BetHandler.getCandidatesOnFirst()[0]
	var firstScore: float = 0#BetHandler.getScores()[firstCandidate]

	if BetHandler.currentBet is GameTimeBet:
		numberShown = BetHandler.currentBet.gameTime
	else:
		numberShown = firstScore
	
	$ScreenLight.light_color = BetHandler.getCandidateColor(firstCandidate)
	
	$SlotWheel_0.rotateTo(floori(numberShown/100))
	$SlotWheel_1.rotateTo(floori(numberShown/10))
	$SlotWheel_2.rotateTo(floori(numberShown) % 10)
