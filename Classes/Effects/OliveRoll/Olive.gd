extends Pushable

var _lastThrower : Monigote

@onready var material : Material = $Aceituna/Sphere.get_surface_override_material(0)
@onready var base_color : Color = material.albedo_color

func _ready():
	rotation.y = randf_range(-PI, PI)

func onPushed(dir : Vector2, factor : float, pusher : Pushable):
	$Shot.play()
	
	_lastThrower = pusher

	super(dir, factor, pusher)

func _process(_delta):
	material.albedo_color = base_color * color

func _on_area_3d_body_entered(body):
	if velocity.is_zero_approx():
		return
	if not body is Monigote or body == _lastThrower:
		return
	
	var monigote := body as Monigote
	monigote.hurt()
	queue_free()
