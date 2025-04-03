@tool
extends GamepadSelectUI
class_name GamepadSelectButton

signal pressed

@export var text : String

## Automáticamente cada frame se fija si está en un hbox o un vbox y setea sus
## vecinos dependiendo de los nodos en su nivel del árbol
@export var autoSetNeighbours := true
@export_tool_button("Set automatic neighbours") var automaticButton = setAutomaticNeighbours
@export_tool_button("Reset neighbours") var resetButton = resetNeighbours

@export_group("Texturas")
@export var normalTexture  : Texture
@export var focusedTexture : Texture
@export var pressedTexture : Texture
@export var underTexture : Texture

func _game_and_editor_process(_delta):
	%Label.text = text
	if !focused:
		%OverTexture.texture = normalTexture
	
	if disabled:
		modulate.a = .5
	else:
		modulate.a = 1
	
	if underTexture != null:
		%UnderTexture.texture = underTexture
	
	if autoSetNeighbours:
		setAutomaticNeighbours()
	
	if !focused or !is_visible_in_tree():
		return
	
	if %OnclickedTime.is_stopped():
		%OverTexture.texture = focusedTexture
	else:
		%OverTexture.texture = pressedTexture

func _in_game_process(_delta):
	if !focused or !is_visible_in_tree():
		return

	if Input.is_action_just_pressed(actions["grab"]):
		pressed.emit()
		%OnclickedTime.start()

func resetNeighbours():
	var directionsPrefix := ["right", "down", "up", "left"]
	for prefix in directionsPrefix:
		set(prefix + "Select", null)
		set(prefix + "Fallback", null)

## Establece los vecinos del botón automáticamente teniendo en cuenta el orden de
## los hijos del container al que pertenece (solo funciona cuando el nodo está en
## un hbox o vbox)
func setAutomaticNeighbours():
	var increasingNeighbourDirectionPrefix : String
	var decreasingNeighbourDirectionPrefix : String
	if get_parent() is HBoxContainer:
		increasingNeighbourDirectionPrefix = "right"
		decreasingNeighbourDirectionPrefix = "left"
	elif get_parent() is VBoxContainer:
		increasingNeighbourDirectionPrefix = "down"
		decreasingNeighbourDirectionPrefix = "up"
	else:
		return
	
	var index := get_index()
	var nextIndex := -1
	var prevIndex := 10000
	var firstIndex := -1
	var lastIndex := -1
	var container := get_parent()
	for i in range(container.get_child_count()):
		var child = container.get_child(i)
		if not child is GamepadSelectButton:
			continue
		lastIndex = i
		if firstIndex == -1:
			firstIndex = i
		if i < index:
			prevIndex = i
		if i > index and nextIndex == -1:
			nextIndex = i
	
	# Para el wrap arround
	nextIndex = max(nextIndex, firstIndex)
	prevIndex = min(prevIndex, lastIndex)
	
	set(increasingNeighbourDirectionPrefix + "Select", container.get_child(nextIndex))
	set(increasingNeighbourDirectionPrefix + "Fallback", container.get_child(nextIndex))
	set(decreasingNeighbourDirectionPrefix + "Select", container.get_child(prevIndex))
	set(decreasingNeighbourDirectionPrefix + "Fallback", container.get_child(prevIndex))

func setLabelColor(color : Color):
	%Label.label_settings.font_color = color
