extends AnimationStep

var result : int
var effectStarted : bool

@onready var die : Die = animationRoot().die

@export var shakeMagnitude := .6
@export var shakeTime := .3

func _onStart() :
	die = animationRoot().die
	result = animationRoot().result
	effectStarted = false

func _onActiveProcess(_delta):
	if (not die.onFloor()) or effectStarted:
		return
	
	effectStarted = true
	
	die.axis_lock_angular_x = false
	die.axis_lock_angular_y = false
	die.axis_lock_angular_z = false
	
	var particles : GPUParticles3D = die.get_node("StompParticles")
	die.get_node("Stomp").play()
	# Hace que las partículas apunten hacia abajo, ignorando la rotación del dado
	particles.rotation = -die.rotation
	particles.rotation.y = 0
	
	particles.emitting = true
	
	# Luz del número que salió
	var light : OmniLight3D = die.get_node("NumberLight")
	light.global_position = die.global_position + Vector3.UP
	
	var lightTween = create_tween()
	lightTween.tween_interval(.4)
	lightTween.tween_property(light, "light_energy", die.numberLightPosition, waitTimeBeforeEnd/2-.4)
	lightTween.tween_property(light, "light_energy", 0, waitTimeBeforeEnd/2)
	
	die.emit_signal("rolled", result)

	get_viewport().get_camera_3d().startShake(shakeMagnitude,shakeTime)
	for i in Input.get_connected_joypads():
		Input.start_joy_vibration(i, .6, .6, shakeTime)
	
	end()
