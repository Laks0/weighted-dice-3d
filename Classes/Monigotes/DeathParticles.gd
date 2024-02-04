extends GPUParticles3D

@export var mesh : PrismMesh

func _ready():
	# Para que cada una tenga un color distinto hay que duplicar
	# el mesh en cada monigote
	draw_pass_1 = mesh.duplicate(true)
	draw_pass_1.material.albedo_color = get_parent().player.color
