extends Control

var controller
@onready var nameEditor : LineEdit = $Settings/TextEdit

@export var defaultName: String
@export var skin: PlayerHandler.Skins

@export var red: Texture2D
@export var blue: Texture2D
@export var yellow: Texture2D
@export var green: Texture2D

@export var added = false

func _ready():
	nameEditor.text = defaultName
	$Settings/Controller.add_item("Keyboard", 0)
	for c in Input.get_connected_joypads():
		$Settings/Controller.add_item("Gamepad " + str(c), c + 2)
	$Settings/Controller.add_item("Keyboard alt", 1)
	
	if skin == PlayerHandler.Skins.RED:
		$Settings/Preview.texture = red
	elif skin == PlayerHandler.Skins.BLUE:
		$Settings/Preview.texture = blue
	elif skin == PlayerHandler.Skins.YELLOW:
		$Settings/Preview.texture = yellow
	elif skin == PlayerHandler.Skins.GREEN:
		$Settings/Preview.texture = green
	
	if getControllerAmount() > skin:
		added = true
		$Settings/Controller.select(skin)
	
	Input.joy_connection_changed.connect(func (device : int, connected : bool):
		if connected:
			$Settings/Controller.add_item("Gamepad " + str(device), device + 2)
		else:
			$Settings/Controller.remove_item($Settings/Controller.get_item_index(device + 2))
		)

func getControllerAmount() -> int:
	return len(Input.get_connected_joypads()) + 1

func _process(_delta):
	controller = $Settings/Controller.get_item_id($Settings/Controller.selected)
	$Settings.visible = added
	$AddCharacter.visible = !added

func _on_AddCharacter_pressed():
	added = true

func _on_Cancel_pressed():
	added = false
