extends AudioStreamPlayer
var firstTrack : String = "Do You Like Kazz"
var trackA : Array[AudioStreamMP3] = []
var trackB : Array[AudioStreamMP3] = []
var currentClip : int = 0

var setList : Dictionary = {
	"Modales Monigotes" :  ["res://Assets/OST/Modales Monigotes - Intro.mp3", "res://Assets/OST/Modales Monigotes - Loop.mp3"],
	"Do You Like Kazz" : ["res://Assets/OST/Do You Like Kazz - Intro.mp3", "res://Assets/OST/Do You Like Kazz - Loop.mp3"]
}
# Called when the node enters the scene tree for the first time.
func _ready():
	trackA = loadTrack(firstTrack)
	trackB = loadTrack("Modales Monigotes")
	print()
	connect("finished", onFinished)
	volume_db = -4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func onFinished():
	currentClip += 1
	playTrack()

func loadTrack(track : String):
	var trackStore : Array[AudioStreamMP3] = []
	for i in range(setList[track].size()):
		print(setList[track][i])
		print(i)
		trackStore.append(load(setList[track][i]))
	return trackStore
		

func unloadTrack(track):
	pass

func playTrack(track : Array = trackA):
	stream = track[currentClip]
	play()
