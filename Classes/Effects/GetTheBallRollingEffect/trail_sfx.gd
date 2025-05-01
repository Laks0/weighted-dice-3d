extends AudioStreamPlayer3D
@onready var trailSound = []
var maxTrails := 5

func _ready() -> void:
	for i in 5:
		trailSound.append(load("res://Assets/SFX/fx_8-ball_trail_" + str(i+1) + ".wav"))

func playSFX(count):
	if count == maxTrails - 1:
		stream = trailSound[4]
	elif count > 3: stream = trailSound[3] 
	else: stream = trailSound[count]
	play()
