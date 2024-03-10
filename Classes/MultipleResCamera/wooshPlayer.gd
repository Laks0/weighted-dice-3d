extends AudioStreamPlayer

var sounds : Dictionary = {
	"zoomToGame" : preload("res://Assets/SFX/wooshTrans.wav"),
	"wooshTrans" : preload("res://Assets/SFX/wooshTrans.wav")
}

func _ready():
	bus = "SFX"

func playSound(sound : String):
	if sound in sounds:
		stream = sounds[sound]
	play()
