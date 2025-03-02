extends AudioStreamPlayer
var firstTrack : String = "Do You Like Kazz"
var loadedTracks : Array[Array] = [[],[]]

var currentClip : int = 0
var currentTrack : int

var setList : Dictionary = {
	"Modales Monigotes" :  ["res://Assets/OST/Modales Monigotes.mp3"],
	"Do You Like Kazz" : ["res://Assets/OST/Do You Like Kazz - Intro.mp3", "res://Assets/OST/Do You Like Kazz - Loop.mp3"]
}

func _ready():
	bus = "OST"
	loadedTracks[0] = loadTrack(firstTrack)
	loadedTracks[1] = loadTrack("Modales Monigotes")
	connect("finished", onFinished)
	volume_db = -4

func onFinished():
	if !stream.loop:
		currentClip += 1
		playTrack(currentTrack)

func loadTrack(track : String):
	var trackStore : Array[AudioStreamMP3] = []
	for i in range(setList[track].size()):
		trackStore.append(load(setList[track][i]))
	return trackStore

func unloadTrack(_track):
	pass

func stopTrack():
	stop()

func playTrack(track : int = 0):
	if currentTrack != track:
		currentClip = 0
	currentTrack  = track
	stream = loadedTracks[track][currentClip]
	play()
	if track == 0:
		volume_db = 0
	else: volume_db = -4
