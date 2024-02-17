extends Node3D

var numberShown: float = 0

func _rotateWheelTo(wheelN : int, n : int):
	var wheel : Node3D = get_node("Wheel_" + str(wheelN))
	var currentN := _getWheelCurrentFace(wheel)
	
	if n == currentN:
		return
	
	if n < currentN:
		wheel.rotation.x = wheel.rotation.x - 2*PI
	
	var rotationTween := create_tween()
	rotationTween.tween_property(wheel, "rotation:x", PI/10 - n*(PI/5), .1)

## Las ruedas empiezan en PI/10 y giran PI/5 por cada número
func _getWheelCurrentFace(wheel : Node3D) -> int:
	return floori((wheel.rotation.x - PI/10) / (PI/5))

func _process(_delta):
	var firstCandidate = BetHandler.getCandidatesInOrder()[0]
	var firstScore: float = BetHandler.getScores()[firstCandidate]
	var firstColor: Color = BetHandler.getCandidateColor(firstCandidate)

	if BetHandler.currentBet is GameTimeBet:
		numberShown = BetHandler.currentBet.gameTime
	else:
		numberShown = firstScore
	
	$FirstPlaceName.text = BetHandler.getCandidateName(firstCandidate)
	$FirstPlaceName.modulate = firstColor
	$FirstPlaceTitle.modulate = firstColor
	$ScreenLight.light_color = firstColor

	_rotateWheelTo(0, floori(numberShown/100))
	_rotateWheelTo(1, floori(numberShown/10))
	_rotateWheelTo(2, floori(numberShown) % 10)
