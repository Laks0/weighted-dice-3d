extends Pushable
class_name CrownGrab

signal coinOut(holder : Monigote)

@export var timeBetweenCoins : float = 1

var _holder :Monigote

func _ready():
	connect("doubled", emit_signal.bind("escaped"))
	
	wasPushed.connect($CoinCooldown.stop.unbind(3))
	beenGrabbed.connect($CoinCooldown.start.bind(timeBetweenCoins))
	onBeingGrabbed.connect(func (_dir : Vector2, _factor : float, pusher : Pushable):
		_holder = pusher)

func onCoinCooldownTimeout() -> void:
	coinOut.emit(_holder)
	$CoinParticles.restart()
