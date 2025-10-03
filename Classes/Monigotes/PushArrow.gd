extends MeshInstance3D

@export var mon : Monigote

@export var progressBar : TextureProgressBar
@export var progressBarBorder : TextureRect

var _flashing := false
var _flashTimer := 0.0
@export var timeBetweenFlashes := .3
@export var flashLength := .1

func _ready():
	progressBar.self_modulate = mon.player.color

func _process(delta):
	visible = mon.grabbing
	progressBar.value = get_parent().forcePercentage if mon.grabbing else .0
	progressBarBorder.visible = visible
	
	rotation.z = -mon.grabDir.angle()
	
	if get_parent().forcePercentage < 1.0:
		progressBarBorder.self_modulate = Color.BLACK
	else:
		_flashTimer += delta
		if _flashing:
			progressBarBorder.self_modulate = Color.WHITE
			if _flashTimer >= flashLength:
				_flashTimer = 0
				_flashing = false
		else:
			progressBarBorder.self_modulate = Color.BLACK
			if _flashTimer >= timeBetweenFlashes:
				_flashTimer = 0
				_flashing = true

func onGrabbedBody(body : Pushable):
	body.attemptedEscape.connect(shake)
	_flashTimer = 0
	_flashing = false
	await mon.pushed
	if not is_instance_valid(body):
		return
	body.attemptedEscape.disconnect(shake)

func shake():
	var shakeTime := .1
	var shakeMagnitude := 50
	var elapsedTime := .0
	while elapsedTime < shakeTime:
		progressBar.position.y = randf_range(-shakeMagnitude, shakeMagnitude)\
			* (shakeTime - elapsedTime) / shakeTime
		elapsedTime += get_process_delta_time()
		await get_tree().process_frame
	
	progressBar.position.y = 0
