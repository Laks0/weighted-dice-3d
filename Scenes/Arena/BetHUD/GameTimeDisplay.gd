extends Control

# IMPORTANTE: los FPs de las animaciones de $ClockAnimations tienen que ser seteadas para que todas
# las animaciones duren un segundo, así se puede controlar más fácil desde onBetStarted

var bet : GameTimeBet
var tween : Tween

@export var backgroundNoise : AnimatedSprite2D

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
			$ClockAnimations.speed_scale = 1/animationTime
			$ClockAnimations.play(str(candidate))
			$ClockAnimations.frame = 0
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
		$ClockAnimations.stop()
	
	$TimeLabel.text = str(floor(bet.gameTime)) + "s"
