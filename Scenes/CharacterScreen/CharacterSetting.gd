extends Control
class_name CharacterSetting

var controller : int
var playerName : String
var playerReady := false

func _process(_delta):
	if controller == Controllers.KB:
		$ControllerLabel.text = "Keyboard"
	elif controller == Controllers.KB2:
		$ControllerLabel.text = "Keyboard alt."
	elif controller == Controllers.AI:
		$ControllerLabel.text = "AI"
	else:
		$ControllerLabel.text = "Gamepad %s" % controller
	 
	modulate.a = .5 if playerReady else 1.0
	$TextEdit.set_process(not playerReady)
	playerName = $TextEdit.text

func _on_ready_pressed():
	SfxHandler.playSound("playerReady")
	playerReady = not playerReady

func _on_cancel_pressed():
	queue_free()

## Se llama cuando todos los jugadores están ready y no hay vuelta atrás
func allReady():
	$TextEdit.visible = false
	$Cancel.visible = false
	$Ready.visible = false
	$Separator.visible = true
	playerReady = false
	
	if playerName != "":
		$ControllerLabel.text = playerName
	
	modulate = Color.WHITE
	set_process(false)
