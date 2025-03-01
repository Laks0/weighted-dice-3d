extends Control

## En píxeles
@export var radius : float

func drawCircle(angleFrom : float, angleTo : float, color : Color):
	var points : PackedVector2Array = [Vector2.ZERO]
	var numberPoints := 32
	for i in range(numberPoints + 1):
		var angle := angleFrom + i * (angleTo - angleFrom) / numberPoints
		points.push_back(Vector2.from_angle(angle) * radius)
	draw_colored_polygon(points, color)

func _draw():
	if not BetHandler.betOngoing:
		return
	if not BetHandler.currentBet is GameTimeBet:
		return
	
	var bet : GameTimeBet = BetHandler.currentBet
	
	drawCircle(-PI/2, 0, BetHandler.getCandidateColor(0))
	drawCircle(0, PI/2, BetHandler.getCandidateColor(1))
	
	var angleInASecond := (PI/2) / bet.times[0]
	var shortAngleEnd := angleInASecond * bet.times[2] - PI/2
	
	drawCircle(PI/2, shortAngleEnd, BetHandler.getCandidateColor(2))
	drawCircle(shortAngleEnd, 3*PI/2, BetHandler.getCandidateColor(3))
