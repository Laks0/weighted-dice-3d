@tool
extends TextureRect

enum {LT = 100, RT}

@export var type : Controllers.ControllerType
@export var xboxTextures : Dictionary[int, Texture] 
@export var psTextures : Dictionary[int, Texture]

@export var _inputDisplayed : InputEvent

@export_dir var keysPath : String

var _lastKeySet : int

var images : Dictionary[StringName, CompressedTexture2D]

func _ready() -> void:
	var files := DirAccess.get_files_at(keysPath)
	for file : String in files:
		if file.ends_with(".png"):
			images[file] = load("%s/%s" % [keysPath, file])

func _process(_delta: float) -> void:
	if type == Controllers.ControllerType.KEYBOARD:
		if _inputDisplayed.physical_keycode == _lastKeySet:
			return
		
		texture = _getTextureForKey(_inputDisplayed)
		_lastKeySet = _inputDisplayed.physical_keycode
	
	var dictionary := xboxTextures
	if type == Controllers.ControllerType.PS:
		dictionary = psTextures
	
	if _inputDisplayed is InputEventJoypadButton:
		texture = dictionary[_inputDisplayed.button_index]
	
	if _inputDisplayed is InputEventJoypadMotion:
		if _inputDisplayed.axis == 4:
			texture = dictionary[LT]
		else:
			texture = dictionary[RT]

func _getTextureForKey(event : InputEventKey) -> Texture:
	var filename = event.as_text_physical_keycode().to_upper()+".png"
	var altFilename = event.as_text_keycode().to_upper()+".png"
	if images.has(filename):
		return images[filename]
	if images.has(altFilename):
		return images[altFilename]
	return null

func isValidBinding(event: InputEvent) -> bool:
	if event is InputEventKey:
		return _getTextureForKey(event) != null
	if event is InputEventJoypadButton:
		return xboxTextures.has(event.button_index)
	if event is InputEventJoypadMotion:
		return event.axis == 4 or event.axis == 5
	return false

func setBinding(input : InputEvent, controllerId : int) -> void:
	if input == null:
		modulate.a = 0
		return
	modulate.a = 1
	if input == _inputDisplayed or not isValidBinding(input):
		return
	
	_inputDisplayed = input
	type = Controllers.getControllerType(controllerId)

func setBindingOnControllersAction(actionName : String, controllerId: int) -> void:
	var events := Controllers.getEventsForAction(actionName, controllerId)
	
	if events.is_empty():
		modulate.a = 0
	else:
		modulate.a = 1
		setBinding(events[0], controllerId)
