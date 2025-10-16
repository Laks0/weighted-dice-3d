extends Pushable
class_name CrownGrab

signal coinOut(holder : Monigote)

@export var timeBetweenCoins : float = 1

var _holder :Monigote

func _ready():
	connect("doubled", emit_signal.bind("escaped"))
	#beenGrabbed.connect($CoinCooldown.start.bind(timeBetweenCoins))
	onBeingGrabbed.connect(func (_dir : Vector2, _factor : float, pusher : Pushable):
		_holder = pusher)
	$CoinCooldown.start()

func onCoinCooldownTimeout() -> void:
	$CoinSFX.play()
	coinOut.emit(_holder)
	$CoinParticles.restart()

func _on_coin_sfx_finished() -> void:
	if _holder is Monigote:
		$CoinSFX.volume_db = -2
		if $CoinSFX.pitch_scale < 1.5:
			$CoinSFX.pitch_scale *= 16.0/15.0
		if $CoinSFX.pitch_scale > 1.5:
			$CoinSFX.pitch_scale = 1.5
	else:
		$CoinSFX.volume_db = -8
		$CoinSFX.pitch_scale = randf_range(0.95, 1.1)

func explode():
	pass


func _on_was_pushed(_dir: Vector2, _factor: float, _pusher: Pushable) -> void:
	_holder = null
