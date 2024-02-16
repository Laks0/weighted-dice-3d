extends Node3D

@export var thumbnails : Array[Texture]

func _rotateWheelTo(wheelN : int, n : int):
	var wheel : Node3D = get_node("Wheel_" + str(wheelN))
	var currentN := _getWheelCurrentFace(wheel)
	
	if n == currentN:
		return
	
	if n < currentN:
		wheel.rotation.x = wheel.rotation.x - 2*PI
	
	var rotationTween := create_tween()
	rotationTween.tween_property(wheel, "rotation:x", PI/10 + n*(PI/5), .1)

## Las ruedas empiezan en PI/10 y giran PI/5 por cada número
func _getWheelCurrentFace(wheel : Node3D) -> int:
	return floori((wheel.rotation.x - PI/10) / (PI/5))

func _ready():
	if BetHandler.currentBet is GameTimeBet:
		$Wheel_0/Numbers.visible = true
		return
	
	$Wheel_0/Textures.visible = true
	for candidate in BetHandler.getCandidates():
		$Wheel_0/Textures.get_node(str(candidate)).texture = thumbnails[candidate]

func _process(_delta):
	if BetHandler.currentBet is GameTimeBet:
		_rotateWheelTo(0, floori(BetHandler.currentBet.gameTime/100))
		_rotateWheelTo(1, floori(BetHandler.currentBet.gameTime/10))
		_rotateWheelTo(2, floori(BetHandler.currentBet.gameTime) % 10)
		return
	
	var firstCandidate = BetHandler.getCandidatesInOrder()[0]
	var firstScore :float = BetHandler.getScores()[firstCandidate]
	
	_rotateWheelTo(0, firstCandidate)
	_rotateWheelTo(1, floori(firstScore/10))
	_rotateWheelTo(2, floori(firstScore) % 10)
