extends VBoxContainer
class_name VirtualKeyboard

signal characterWritten(char : String)
signal deleteCharacter
signal accept
signal space

@export var capsLockTextureNormal : Texture
@export var capsLockTextureFocus : Texture
@export var capsLockTexturePressed : Texture

@export var upperTextureNormal : Texture
@export var upperTextureFocus : Texture
@export var upperTexturePressed : Texture

@export var lowerTextureNormal : Texture
@export var lowerTextureFocus : Texture
@export var lowerTexturePressed : Texture

const ACCENT_UNICODE := 0x0301

var capsLock := false
var upper := true
var accentsOn := false

func _ready():
	%Space.pressed.connect(space.emit)
	
	for y in get_child_count():
		var row : HBoxContainer = get_child(y)
		row.get_child(0).leftSelect = row.get_child(row.get_child_count()-1)
		row.get_child(row.get_child_count()-1).rightSelect = row.get_child(0)
		for x in range(row.get_child_count()):
			var button : GamepadSelectButton = row.get_child(x)
			if x < row.get_child_count() - 1:
				button.rightSelect = row.get_child(x+1)
			if x > 0:
				button.leftSelect = row.get_child(x-1)
			if y > 0:
				button.upSelect = get_child(y-1).get_child(min(x, get_child(y-1).get_child_count()-1))
			if y < get_child_count() - 1:
				button.downSelect = get_child(y+1).get_child(min(x, get_child(y+1).get_child_count()-1))
			
			if button.text == "E":
				button.text += char(0x0301)
			button.pressed.connect(func ():
				if button == %Shift:
					if capsLock:
						setLowercase()
						return
					if upper:
						setCapsLock()
						return
					setUppercase()
					return
				if button == %Delete:
					deleteCharacter.emit()
					return
				if button == %OK:
					accept.emit()
					return
				if button == %Accent:
					switchAccents()
					return
				
				characterWritten.emit(button.text)
				
				if upper and not capsLock:
					setLowercase()
				if accentsOn:
					switchAccents()
			)
	
	await get_tree().process_frame

func setCapsLock():
	capsLock = true
	setUppercase()
	%Shift.focusedTexture = capsLockTextureFocus
	%Shift.pressedTexture = capsLockTexturePressed
	%Shift.normalTexture = capsLockTextureNormal

func setUppercase():
	%Shift.focusedTexture = upperTextureFocus
	%Shift.pressedTexture = upperTexturePressed
	%Shift.normalTexture = upperTextureNormal
	upper = true
	for row in get_children():
		for button in row.get_children():
			button.text = button.text.to_upper()

func setLowercase():
	%Shift.focusedTexture = lowerTextureFocus
	%Shift.pressedTexture = lowerTexturePressed
	%Shift.normalTexture = lowerTextureNormal
	upper = false
	capsLock = false
	for row in get_children():
		for button in row.get_children():
			button.text = button.text.to_lower()

func switchAccents():
	accentsOn = not accentsOn
	%Accent/Label.label_settings.font_color = Color.WHITE if accentsOn else Color.BLACK
	for row in get_children():
		for button in row.get_children():
			if not "aeiou".containsn(button.text.left(1)):
				continue
			if accentsOn:
				button.text += char(ACCENT_UNICODE)
			else:
				button.text = button.text.left(1)

func focus():
	unfocus()
	%OK.focus()

func unfocus():
	for row in get_children():
		for button in row.get_children():
			button.unfocus()

func setController(controller : int):
	for row in get_children():
		for button in row.get_children():
			button.controller = controller
