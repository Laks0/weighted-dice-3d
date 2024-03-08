extends AudioStreamPlayer

var sounds : Dictionary = {
	"zoomToGame" : preload("res://Assets/SFX/wooshTrans.wav"),
	"wooshTrans" : preload("res://Assets/SFX/wooshTrans.wav")
}
# Called when the node enters the scene tree for the first time.
func _ready():
	bus = "SFX"

func playSound(sound : String):
	if sound in sounds:
		stream = sounds[sound]
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
