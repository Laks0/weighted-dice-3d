extends Control
class_name CharacterSetting

var controller : int
var playerName : String
var playerReady := false

func _ready():
	$VirtualKeyboard.setController(controller)
	$Cancel.controller = controller
	$Ready.controller = controller
	
	$VirtualKeyboard.characterWritten.connect(func(c : String):
		$TextEdit.text = $TextEdit.text + c)
	$VirtualKeyboard.deleteCharacter.connect(func():
		if $TextEdit.text.length() == 0:
			return
		$TextEdit.text = $TextEdit.text.erase($TextEdit.text.length()-1, 1))
	
	if controller != Controllers.KB and controller != Controllers.KB2:
		startVirtualKeyboard()
		$TextEdit.focus_mode = FOCUS_NONE
		$TextEdit.mouse_filter = MOUSE_FILTER_IGNORE
	
	$Ready.movedUp.connect(startVirtualKeyboard)
	$VirtualKeyboard.accept.connect(endVirtualKeyboard)

func _process(_delta):
	$Ready.canMoveFocus = not playerReady
	
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

func startVirtualKeyboard():
	$Cancel.visible = false
	$Ready.visible = false
	$VirtualKeyboard.visible = true
	$Cancel.unfocus()
	$Ready.unfocus()
	$VirtualKeyboard.focus()

func endVirtualKeyboard():
	$VirtualKeyboard.visible = false
	$Cancel.visible = true
	$Ready.visible = true
	$VirtualKeyboard.unfocus()
	$Ready.focus()

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
