extends TextureRect
class_name CharacterSetting

@export var maxNameLength : int = 10

var _controller : int = 0
var playerName := ""

enum Stages { WAITING, MAIN, NAME_EDIT, CONTROLLERS, READY, LOCKED, ALLREADY}
var stage := Stages.WAITING

var active := false

func _ready():
	%VirtualKeyboard.focus()
	$FromWaitTransition.visible = stage == Stages.WAITING
	custom_minimum_size = size

func setController(arr : Array):
	for c in arr:
		setController(c.get_children())
		if not c is GamepadSelectButton:
			continue
		c.controller = _controller

func activate(controller : int):
	_controller = controller
	active = true
	
	%VirtualKeyboard.setController(controller)
	setController(get_children())
	
	$FromWaitTransition.play()
	stage = Stages.MAIN
	await $FromWaitTransition.animation_finished
	$FromWaitTransition.visible = false
	%EditNameButton.focus()

func deactivate():
	active = false
	$FromWaitTransition.visible = true
	$FromWaitTransition.play_backwards()
	await $FromWaitTransition.animation_finished
	playerName = ""
	stage = Stages.WAITING
	%ExitButton.unfocus()
	%EditNameButton.unfocus()
	%StartButton.unfocus()
	%ControllersButton.unfocus()

func _process(_delta):
	$MainStage.visible = stage == Stages.MAIN
	$NameEdit.visible = stage == Stages.NAME_EDIT
	$ReadyStage.visible = stage == Stages.READY
	$WaitingStage.visible = stage == Stages.WAITING
	$ControlsStage.visible = stage == Stages.CONTROLLERS
	$LockedStage.visible = stage == Stages.LOCKED
	if stage == Stages.MAIN:
		mainProcess()
	if stage == Stages.NAME_EDIT:
		editProcess()
	if stage == Stages.CONTROLLERS:
		controllersProcess()

func getControllerName() -> String:
	if _controller < Controllers.KB:
		return "Gamepad " + str(_controller+1)
	if _controller == Controllers.KB:
		return "Main keyboard"
	return "Keyboard alt."

func mainProcess():
	if playerName != "":
		%PlayerNameLabel.text = playerName
	else:
		%PlayerNameLabel.text = getControllerName()

func editProcess():
	%PlayerNameEditLabel.text = playerName

func controllersProcess():
	if _controller == Controllers.KB:
		%ControlsText.text = "Espacio para agarrar\nspam de espacio para escaparse\nwasd para moverse"
	elif _controller == Controllers.KB2:
		%ControlsText.text = "Altgr para agarrar\nspam de altgr para escaparse\nflechas para moverse"
	else:
		%ControlsText.text = "X para agarrar\nspam de X para escaparse\njoystick/dpad para moverse"

var transitioning_stage := Stages.MAIN
func transition(to : Stages):
	$Transition.visible = true
	$Transition.play()
	transitioning_stage = to

func onTransitionFrameChanged():
	if $Transition.frame == 5:
		stage = transitioning_stage

func onTransitionAnimationFinished():
	$Transition.visible = false

func onVirtualKeyboardCharacterWritten(char):
	if len(playerName) >= maxNameLength:
		return
	playerName += char

func onVirtualKeyboardDeleteCharacter():
	if len(playerName) > 0:
		playerName = playerName.erase(len(playerName)-1, 1)

func isActive():
	return active

func isReady():
	return stage == Stages.READY

func waitForKeyboard():
	stage = Stages.LOCKED

func stopWaiting():
	if stage != Stages.LOCKED:
		return
	transition(Stages.MAIN)

func allReady():
	stage = Stages.ALLREADY
	texture = null
	for c in get_children():
		c.visible = false
	%AllReadyPlayerName.text = playerName
	if playerName == "" and active:
		%AllReadyPlayerName.text = getControllerName()
	%AllReadyPlayerName.visible = true

func getController() -> int:
	return _controller
