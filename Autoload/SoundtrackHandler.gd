extends AudioStreamPlayer
var firstTrack : String = "Do You Like Kazz"
var loadedTracks : Array[Array] = []

var currentClip : int = 0
var currentTrack : int

var setList : Dictionary = {
	"Do You Like Kazz" : ["res://Assets/OST/Do You Like Kazz - Intro.mp3", "res://Assets/OST/Do You Like Kazz - Loop.mp3"],
	"Modales Monigotes" :  ["res://Assets/OST/Modales Monigotes.mp3"],
	"Tragos, Tratos y Timbas - Ronda 2" : ["res://Assets/OST/Tragos, Tratos y Timbas - Ronda 2.mp3"],
	"Tragos, Tratos y Timbas - Ronda 3" :["res://Assets/OST/Tragos, Tratos y Timbas - Ronda 3.mp3"],
	"Tragos, Tratos y Timbas - Ronda 4" :["res://Assets/OST/Tragos, Tratos y Timbas - Ronda 4.mp3"]
}

func _ready():
	bus = "OST"
	loadedTracks.append(loadTrack(firstTrack)) #0
	loadedTracks.append(loadTrack("Modales Monigotes")) #1
	loadedTracks.append(loadTrack("Tragos, Tratos y Timbas - Ronda 2")) #2
	loadedTracks.append(loadTrack("Tragos, Tratos y Timbas - Ronda 3")) #3
	loadedTracks.append(loadTrack("Tragos, Tratos y Timbas - Ronda 4")) #4
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

#despues exportar a volumen correcto y sacar esto
	if track == 0:
		volume_db = 0
	elif track >= 2 && track <=4:
		volume_db = 3
	else: volume_db = -4
