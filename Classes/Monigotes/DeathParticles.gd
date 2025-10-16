extends GPUParticles3D

@export var mesh : PrismMesh
@export var mon : Monigote

func _ready():
	# Para que cada una tenga un color distinto hay que duplicar
	# el mesh en cada monigote
	draw_pass_1 = mesh.duplicate(true)
	draw_pass_1.material.albedo_color = mon.player.color
