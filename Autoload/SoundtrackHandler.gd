extends AudioStreamPlayer
var firstTrack : String = "Do You Like Kazz"
var loadedTracks : Array[Array] = [[],[]]

var currentClip : int = 0
var currentTrack : int

var setList : Dictionary = {
	"Modales Monigotes" :  ["res://Assets/OST/Modales Monigotes - Intro.mp3", "res://Assets/OST/Modales Monigotes - Loop.mp3"],
	"Do You Like Kazz" : ["res://Assets/OST/Do You Like Kazz - Intro.mp3", "res://Assets/OST/Do You Like Kazz - Loop.mp3"]
}
# Called when the node enters the scene tree for the first time.
func _ready():
	loadedTracks[0] = loadTrack(firstTrack)
	loadedTracks[1] = loadTrack("Modales Monigotes")
	print()
	connect("finished", onFinished)
	volume_db = -4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func onFinished():
	if currentClip == 0:
		currentClip += 1
	playTrack(currentTrack)

func loadTrack(track : String):
	var trackStore : Array[AudioStreamMP3] = []
	for i in range(setList[track].size()):
		print(setList[track][i])
		print(i)
		trackStore.append(load(setList[track][i]))
	return trackStore
		

func unloadTrack(track):
	pass

func stopTrack():
	stop()

func playTrack(track : int = 0):
	if currentTrack != track:
		currentClip = 0
	currentTrack  = track
	stream = loadedTracks[track][currentClip]
	print(currentTrack)
	play()
