extends AudioStreamPlayer2D

@onready var rollSound = []
var internalCount = 0



@export var volumeDecreaseFactor := 80
@export var defaultRollVolume := 0
@export var rollFadeOut := 0.4
@onready var newRollVolume = defaultRollVolume

@onready var ball8 = get_parent()

var isRollSFXMute := false
var isRollSFXTweening := false

func _ready() -> void:
	for i in 5:
		rollSound.append(load("res://Assets/SFX/fx_8-ball_roll_" + str(i+1) + ".wav"))
	

func playSFX():
	var count = ball8.rollCounter
	if count > 4:
		internalCount = 4   #se asegura de repetir el último sonido disponible si hay demasiados bumps
	else: internalCount = count
	stream = rollSound[internalCount]
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
