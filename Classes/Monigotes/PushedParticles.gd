extends GPUParticles3D

@onready var mon : Monigote = get_parent()

func _physics_process(_delta):
	if mon.velocity.is_zero_approx():
		emitting = false
		mon.unclampedVelocity = Vector2.ZERO

func _on_monigote_pushed(_dir, factor : float, _pusher):
	# Solo las genera a partir de factor .5
	if factor < .5:
		return
	
	# Se espera un poco antes de crear las partículas
	await get_tree().create_timer(.1).timeout
	
	amount = floor(factor * 3)
	emitting = true
