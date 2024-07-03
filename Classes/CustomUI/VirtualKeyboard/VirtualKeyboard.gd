extends VBoxContainer
class_name VirtualKeyboard

signal characterWritten(char : String)
signal deleteCharacter
signal accept

var capsLock := false
var upper := true

func _ready():
	for y in get_child_count():
		var row : HBoxContainer = get_child(y)
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
				characterWritten.emit(button.text)
				
				if upper and not capsLock:
					setLowercase()
			)
	
	await get_tree().process_frame

func _process(_delta):
	if capsLock:
		%Shift.text = "  ⬆  "
	elif upper:
		%Shift.text = "  ⇧  "
	else:
		%Shift.text = "  ↑  "

func setCapsLock():
	capsLock = true
	setUppercase()

func setUppercase():
	upper = true
	for row in get_children():
		for button in row.get_children():
			button.text = button.text.to_upper()

func setLowercase():
	upper = false
	capsLock = false
	for row in get_children():
		for button in row.get_children():
			button.text = button.text.to_lower()

func focus():
	%OK.focus()

func unfocus():
	for row in get_children():
		for button in row.get_children():
			button.unfocus()

func setController(controller : int):
	for row in get_children():
		for button in row.get_children():
			button.controller = controller
