extends AudioStreamPlayer

var sounds : Dictionary = {
	"buttonHighlight" : preload("res://Assets/SFX/buttonHighlight.wav"),
	"buttonSelect" : preload("res://Assets/SFX/buttonSelect.wav"),
	"controllerLogin" : preload("res://Assets/SFX/controllerLogin.wav"),
	"playerReady" : preload("res://Assets/SFX/playerReady.wav"),
	"pointerSelect" : preload("res://Assets/SFX/pointerSelect.wav"),
	"pointerCancel" : preload("res://Assets/SFX/pointerCancel.wav"),
	"pointerMove" : preload("res://Assets/SFX/pointerMove.wav"),
	"readyCancel" : preload("res://Assets/SFX/pointerCancel.wav"),
	"displayReady" : preload("res://Assets/SFX/displayReady.wav"),
	"pointerCantMove" : preload("res://Assets/SFX/pointerCantMove.wav"),
	"keyboardScroll" : preload("res://Assets/SFX/fx_menu_keyboard_scroll.wav")
}

func _ready():
	bus = "SFX"

func playSound(sound : String):
	if sound in sounds:
		stream = sounds[sound]
	play()
