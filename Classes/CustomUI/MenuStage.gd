@tool
extends Resource
class_name MenuStage

signal requestTransition(newStageName : StringName)

@export var invisibleNodes : Array[NodePath]
@export var visibleNodes : Array[NodePath]
## Por defecto el disable de los nodos no se toca a menos que esté explícito en
## disabledNodes o enabledNodes
@export var disabledNodes : Array[NodePath]
## Ver disabledNodes
@export var enabledNodes : Array[NodePath]

@export var focusedNode : NodePath
## En la clave va el botón para la transición y en el valor el nombre del stage
## al que transiciona (se llama a requestTransition)
@export var transitionButtons : Dictionary[NodePath, StringName]

# Es para tener acceso al tree y poder usar nodos
var _menuParent : MultiStageMenu
var _active := false

func start(menu : Node):
	if _active:
		return
	_menuParent = menu
	_active = true
	for n in invisibleNodes:
		menu.get_node(n).visible = false
	for n in visibleNodes:
		if menu.get_node(n) is GamepadSelectUI:
			menu.get_node(n).unfocus()
		menu.get_node(n).visible = true
	for n in disabledNodes:
		menu.get_node(n).disabled = true
	for n in enabledNodes:
		menu.get_node(n).disabled = false
	
	await menu.get_tree().process_frame
	await menu.get_tree().process_frame
	await menu.get_tree().process_frame
	await menu.get_tree().process_frame
	
	menu.get_node(focusedNode).focus()
	_updateTransitionButtons(transitionButtons)

## Pone en invisible todos los nodos en visibleNodes
func end():
	if not _active:
		return
	_active = false
	for n in visibleNodes:
		if _menuParent.get_node(n) is GamepadSelectUI:
			_menuParent.get_node(n).unfocus()
		_menuParent.get_node(n).visible = false

func _updateTransitionButtons(newVal : Dictionary[NodePath, StringName]):
	for b in transitionButtons.keys():
		var button : GamepadSelectButton = _menuParent.get_node(b)
		var c := requestTransition.emit.bind(transitionButtons[b])
		if button.pressed.is_connected(c):
			button.pressed.disconnect(c)
	transitionButtons = newVal
	for b in transitionButtons.keys():
		var button : GamepadSelectButton = _menuParent.get_node(b)
		var c := requestTransition.emit.bind(transitionButtons[b])
		button.pressed.connect(c)
