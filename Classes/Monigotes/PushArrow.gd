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
