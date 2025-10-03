extends AudioStreamPlayer2D

var internalCount = 0



@export var volumeDecreaseFactor := 80
@export var defaultRollVolume := 0
@export var rollFadeOut := 0.4
@onready var newRollVolume = defaultRollVolume

@onready var ball8 = get_parent()

var isRollSFXMute := false
var isRollSFXTweening := false

	

func playSFX():
	play()
	volume_db = defaultRollVolume
	newRollVolume = defaultRollVolume

func _process(_delta: float) -> void:
	if ball8.movingSpeed < 10:
		var volumeTarget : float = defaultRollVolume+(volumeDecreaseFactor*(ball8.movingSpeed-10)/10)
		if not isRollSFXTweening:
			if abs(volumeTarget - newRollVolume) < 10:
				newRollVolume = volumeTarget
				volume_db = volumeTarget
			else:
				if ball8.movingSpeed > 0 or not isRollSFXMute:
					var rollVolumeTween := create_tween()
					rollVolumeTween.tween_property(self, "volume_db", volumeTarget, rollFadeOut)
					rollVolumeTween.tween_callback(func():isRollSFXTweening = false)
					isRollSFXTweening = true
					if ball8.movingSpeed == 0: isRollSFXMute = true
					else: isRollSFXMute = false
