extends Pushable
class_name BettingChip

var player : PlayerHandler.Player

func setPlayer(p : PlayerHandler.Player):
	player = p
	# Super específico a como es la mesh de la ficha. (DEBUG)
	var material := StandardMaterial3D.new()
	material.albedo_color = p.color
	$FichaPoker.set_surface_override_material(0, material)
	$FichaPoker.set_surface_override_material(2, material)

func onPushed(dir : Vector2, factor : float):
	super(dir, factor)
	var velocity2d = maxPushForce * dir * factor
	velocity = Vector3(velocity2d.x, 0, velocity2d.y)

func _physics_process(delta):
	velocity = lerp(velocity, Vector3.ZERO, .12)
	super(delta)
	move_and_slide()
