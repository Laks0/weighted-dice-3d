extends Node

# -1 es el teclado, después el número de control
enum {KB = 0, KB2, D0}

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
	D0: {
		"up": "move_up_d0",
		"down": "move_down_d0",
		"right": "move_right_d0",
		"left": "move_left_d0",
		"grab": "grab_d0",
	},
}

func getDirection(controller : int) -> Vector2:
	var input = controllers[controller]
	
	var up = input["up"]
	var down = input["down"]
	var left = input["left"]
	var right = input["right"]
	
	return Input.get_vector(left, right, up, down)

func getActions(inputController : int) -> Dictionary:
	return controllers[inputController]
