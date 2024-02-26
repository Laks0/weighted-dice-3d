extends Node

# 0 y 1 son el teclado, después el número de control + 2
enum {KB = 0, KB2, AI = 1000}

var controllers = {
	KB: {
		"up": "move_up_kb",
		"down": "move_down_kb",
		"right": "move_right_kb",
		"left": "move_left_kb",
		"grab": "grab_mouse",
	},
	KB2: {
		"up": "move_up_kb2",
		"down": "move_down_kb2",
		"right": "move_right_kb2",
		"left": "move_left_kb2",
		"grab": "grab_kb2",
	},
	AI: {
		"up": "empty",
		"down": "empty",
		"right": "empty",
		"left": "empty",
		"grab": "empty",
	},
}

func _ready():
	for id in Input.get_connected_joypads():
		addController(id)
	
	Input.joy_connection_changed.connect(func (device : int, connected : bool):
		if connected:
			addController(device))

func addController(id : int):
	if controllers.has(id + 2):
		return
	
	controllers[id + 2] = {}
	addMovementAction("up", JOY_BUTTON_DPAD_UP, JOY_AXIS_LEFT_Y, -1, id)
	addMovementAction("down", JOY_BUTTON_DPAD_DOWN, JOY_AXIS_LEFT_Y, 1, id)
	addMovementAction("left", JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1, id)
	addMovementAction("right", JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1, id)
	
	InputMap.add_action("grab_d%s" % id)
	controllers[id+2]["grab"] = "grab_d%s" % id
	addButtonToAction("grab_d%s" % id, JOY_BUTTON_A, id)

func addMovementAction(dir : String, button : JoyButton, axis : JoyAxis, axisDir : float, device : int):
	var action = "move_" + dir + "_d%s" % device
	InputMap.add_action(action)
	controllers[device+2][dir] = action
	addButtonToAction(action, button, device)
	addStickToAction(action, axis, axisDir, device)

func addButtonToAction(action : String, button : JoyButton, device : int):
	var event = InputEventJoypadButton.new()
	event.set_device(device)
	event.set_button_index(button)
	InputMap.action_add_event(action, event)

func addStickToAction(action : String, axis : JoyAxis, dir : float, device : int):
	var event = InputEventJoypadMotion.new()
	event.set_device(device)
	event.set_axis(axis)
	event.set_axis_value(dir)
	InputMap.action_add_event(action, event)

func getDirection(controller : int) -> Vector2:
	var input = controllers[controller]
	
	var up = input["up"]
	var down = input["down"]
	var left = input["left"]
	var right = input["right"]
	
	return Input.get_vector(left, right, up, down)

func getActions(inputController : int) -> Dictionary:
	return controllers[inputController]
