extends Node

# -1 es el teclado, después el número de control
enum {KB = 0, KB2, D0, D1, D2, D3}

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
	D1: {
		"up": "move_up_d1",
		"down": "move_down_d1",
		"right": "move_right_d1",
		"left": "move_left_d1",
		"grab": "grab_d1",
	},
	D2: {
		"up": "move_up_d2",
		"down": "move_down_d2",
		"right": "move_right_d2",
		"left": "move_left_d2",
		"grab": "grab_d2",
	},
	D3: {
		"up": "move_up_d3",
		"down": "move_down_d3",
		"right": "move_right_d3",
		"left": "move_left_d3",
		"grab": "grab_d3",
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
