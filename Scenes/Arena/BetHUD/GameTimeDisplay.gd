extends Control

# IMPORTANTE: los FPs de las animaciones de $ClockAnimations tienen que ser seteadas para que todas
# las animaciones duren un segundo, así se puede controlar más fácil desde onBetStarted

var bet : GameTimeBet
var tween : Tween

@export var backgroundNoise : AnimatedSprite2D

## Tiempo antes de una marca en el que empieza el sfx
@export var warningTimeStart : float = 3

func _ready():
	BetHandler.betStarted.connect(onBetStarted)

func onBetStarted():
	if not BetHandler.currentBet is GameTimeBet:
		return
	
	visible = true
	bet = BetHandler.currentBet
	
	var times := bet.times
	tween = create_tween()
	for candidate in BetHandler.getCandidates():
		var animationTime := 10.0
		# Los tiempos son acumulados en times, hay que derivarlos
		if candidate == 0:
			animationTime = times[0]
		elif candidate < times.size():
			animationTime = times[candidate] - times[candidate - 1]
		
		tween.tween_callback(func ():
			backgroundNoise.modulate = BetHandler.getCandidateColor(candidate)
		)
		tween.tween_interval(animationTime)

func reset():
	if not visible:
		return
	
	tween.kill()
	backgroundNoise.modulate = Color.WHITE
	visible = false

func _process(_delta):
	if (not visible) or (not is_instance_valid(bet)):
		return
	
	if not BetHandler.betOngoing:
		tween.stop()
	
	$TimeLabel.text = "%s" % floor(bet.gameTime)
	var anglePerSecond := (PI/2) / bet.times[0]
	%ClockHand.rotation = clamp(-PI/2 + bet.gameTime * anglePerSecond, -PI/2, 3*PI/2)
	
	for t in bet.times:
		if $Countdown.playing:
			break
		if bet.gameTime > t - warningTimeStart and bet.gameTime < t:
			$Countdown.play()
			break
