extends Control
class_name CharacterSetting

var controller : int
var playerName : String
var playerReady := false

var edittingName := false
## Marca si es un teclado que está esperando a que termine el otro
var waiting := false

func _ready():
	$VirtualKeyboard.setController(controller)
	
	$VirtualKeyboard.characterWritten.connect(func(c : String):
		$TextEdit.text = $TextEdit.text + c)
	$VirtualKeyboard.deleteCharacter.connect(func():
		if $TextEdit.text.length() == 0:
			return
		$TextEdit.text = $TextEdit.text.erase($TextEdit.text.length()-1, 1))
	
	if not Controllers.isKeyboard(controller):
		$TextEdit.focus_mode = FOCUS_NONE
		$TextEdit.mouse_filter = MOUSE_FILTER_IGNORE
	else:
		$KeyboardHints.visible = true
	
	$VirtualKeyboard.accept.connect(endVirtualKeyboard)
	
	await get_tree().process_frame
	
	startEdit()

func _process(_delta):
	if controller == Controllers.KB:
		$ControllerLabel.text = "Keyboard"
		
		$KeyboardHints.text = "Espacio: Listo/No listo\nE: editar\nQ: eliminar"
	elif controller == Controllers.KB2:
		$ControllerLabel.text = "Keyboard alt."
		
		$KeyboardHints.text = "AltGr: Listo/No listo\n+ : editar\n- : eliminar"
	elif controller == Controllers.AI:
		$ControllerLabel.text = "AI"
	else:
		$ControllerLabel.text = "Gamepad %s" % controller
	
	modulate.a = .5 if playerReady else 1.0
	$TextEdit.set_process(not playerReady)
	playerName = $TextEdit.text
	
	if Controllers.isKeyboard(controller):
		edittingName = $TextEdit.has_focus()
	
	if edittingName:
		$KeyboardHints.text = "Esc para terminar"
	elif waiting:
		$KeyboardHints.text = "Esperá a que termine el otro teclado"
	
	# Opciones
	if edittingName or waiting:
		return
	
	var actions := Controllers.getActions(controller)
	if Input.is_action_just_pressed(actions["ui_ok"]):
		toggleReady()
	
	if Input.is_action_just_pressed(actions["ui_cancel"]):
		queue_free()
	
	if Input.is_action_just_pressed(actions["ui_edit"]):
		startEdit()

func toggleReady():
	SfxHandler.playSound("playerReady")
	playerReady = not playerReady

func startEdit():
	if waiting:
		return
	
	edittingName = true
	playerReady = false
	if controller == Controllers.KB or controller == Controllers.KB2:
		$TextEdit.grab_focus()
		return
	startVirtualKeyboard()

func startVirtualKeyboard():
	$VirtualKeyboard.visible = true
	$VirtualKeyboard.focus()
	$GamepadHints.visible = false

func endVirtualKeyboard():
	$VirtualKeyboard.visible = false
	$VirtualKeyboard.unfocus()
	$GamepadHints.visible = true
	edittingName = false

## Se llama cuando todos los jugadores están ready y no hay vuelta atrás
func allReady():
	$TextEdit.visible = false
	$Separator.visible = true
	$KeyboardHints.visible = false
	$GamepadHints.visible = false
	playerReady = false
	
	if playerName != "":
		$ControllerLabel.text = playerName
	
	modulate = Color.WHITE
	set_process(false)
