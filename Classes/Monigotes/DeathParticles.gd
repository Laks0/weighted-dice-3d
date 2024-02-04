extends GPUParticles3D

@export var mesh : PrismMesh

func _ready():
	draw_pass_1 = mesh.duplicate(true)
	draw_pass_1.material.albedo_color = get_parent().player.color
