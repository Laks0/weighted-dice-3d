extends MeshInstance3D

@onready var mon : Monigote = get_parent()

@export var progressBar : TextureProgressBar
@export var progressBarBorder : TextureRect

func _ready():
	material_override.albedo_color = mon.player.color

func _process(_delta):
	visible = mon.grabbing
	progressBar.value = mon.forceGrabbing if mon.grabbing else .0
	if not visible:
		progressBarBorder.visible = false
		return
	
	rotation.z = -mon.grabDir.angle()
	progressBarBorder.visible = mon.forceGrabbing == 1.0

func onGrabbedBody(body : Pushable):
	body.attemptedEscape.connect(shake)
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
