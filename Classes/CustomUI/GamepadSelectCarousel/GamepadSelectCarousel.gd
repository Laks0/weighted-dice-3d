@tool
extends GamepadSelectUI

@export var selected := 0
## Las opciones del carrusel. Las claves del diccionario es lo que aparece en
## pantalla y los valores sus ids.
@export var options : Dictionary[String, String]: set = changeOptions
@export_tool_button("Center to selected") var y = moveToSelected

var selectedLabel : Label
var boxPositionX : float = 0

func _ready():
	%HBoxContainer.theme = get_theme()
	resetOptionLabels()
	await get_tree().process_frame
	moveToSelected(0)

func _game_and_editor_process(_delta):
	setSize()
	
	if options.size() == 0 or selected >= options.size():
		return
	
	%HBoxContainer.position.x = boxPositionX
	
	for label : Label in %HBoxContainer.get_children():
		label.modulate.a = 1.0 if label == selectedLabel else .5
	
	$Arrows.modulate = Color.WHITE if focused else Color.BLACK

# Se sobreescriben los movimientos de izquierda y derecha para no cambiar el focus
func _handle_movement():
	var movement := _get_current_movement()
	if not movement in [RIGHT, LEFT]:
		super()
		return
	
	$AudioStreamPlayer.play()
	moveCarousel(movement)

func changeOptions(val : Dictionary[String, String]):
	options = val
	if get_node_or_null("%HBoxContainer") != null:
		resetOptionLabels()
		moveToSelected()

func resetOptionLabels():
	selected = min(selected, options.size() - 1)
	for c in %HBoxContainer.get_children():
		c.queue_free()
	
	for optionName : String in options.keys():
		var label := Label.new()
		label.text = optionName
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		%HBoxContainer.add_child(label)
	
	updateSelectedLabel()

func moveCarousel(dir : int):
	var indexMovement := 1 if dir == RIGHT else -1
	selected = (selected + indexMovement + options.size()) % options.size()
	updateSelectedLabel()
	moveToSelected()
	_animateArrow(dir)

func moveToSelected(time := .1):
	updateSelectedLabel()
	var newPosition :float= -selectedLabel.position.x - selectedLabel.size.x/2 + $SubViewportContainer.size.x/2
	create_tween().tween_property(self, "boxPositionX", newPosition, time)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func updateSelectedLabel():
	selectedLabel = %HBoxContainer.get_child(selected)

func getSelectedId() -> String:
	return options[selectedLabel.text]

func setSize():
	var maxLabelWidth : float = 0
	for label : Label in %HBoxContainer.get_children():
		maxLabelWidth = max(maxLabelWidth, label.size.x)
	
	custom_minimum_size.x = maxLabelWidth * 2
	%SubViewport.size.x = custom_minimum_size.x

func _animateArrow(dir : int):
	var arrowToAnimate : TextureRect
	if dir == LEFT:
		arrowToAnimate = %LeftArrow
	else:
		arrowToAnimate = %RightArrow
	
	var originalPos : float = arrowToAnimate.position.y
	var tween := create_tween()
	tween.tween_property(arrowToAnimate, "position:y", originalPos - 10, .05)
	tween.tween_property(arrowToAnimate, "position:y", originalPos, .05)
