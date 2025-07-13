extends TextureRect
class_name CharacterSetting

signal keyboardStartedEdittingController
signal keyboardStoppedEdittingController

@export var maxNameLength : int = 10

var _controller : int = 0
var playerName := ""

enum Stages { WAITING, MAIN, NAME_EDIT, CONTROLLERS, READY, LOCKED, ALLREADY}
var stage := Stages.WAITING

var active := false

@export_range(1,6) var color : int = 1

func _ready():
	$Sombra/Marco.texture.region.position.x *= color
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
	
	%ConfigControllers.setControllerId(controller)

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
	
	%PlayerNameLabel.add_theme_color_override("font_color", Color.BLACK)
	if %EditNameButton.focused:
		%PlayerNameLabel.add_theme_color_override("font_color", Color.WHITE)

func editProcess():
	%PlayerNameEditLabel.text = playerName

var transitioning_stage := Stages.MAIN
func transition(to : Stages):
	if to == Stages.CONTROLLERS and Controllers.isKeyboard(_controller):
		keyboardStartedEdittingController.emit()
	if stage == Stages.CONTROLLERS and Controllers.isKeyboard(_controller):
		keyboardStoppedEdittingController.emit()
	
	$Transition.visible = true
	$Transition.play()
	transitioning_stage = to

func onTransitionFrameChanged():
	if $Transition.frame == 5:
		stage = transitioning_stage

func onTransitionAnimationFinished():
	$Transition.visible = false

func onVirtualKeyboardCharacterWritten(c):
	if len(playerName) >= maxNameLength:
		return
	playerName += c

func onVirtualKeyboardDeleteCharacter():
	if len(playerName) > 0:
		playerName = playerName.erase(len(playerName)-1, 1)

func onOtherKeyboardStartedEditting():
	if Controllers.isKeyboard(_controller):
		%ControllersButton.disable()

func onOtherKeyboardStoppedEditting():
	if Controllers.isKeyboard(_controller):
		%ControllersButton.enable()

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
