extends Pushable

var _lastThrower : Monigote

func _ready():
	$AnimatedSprite3D.frame = randi_range(0, 7)
	
	super()

func onPushed(dir : Vector2, factor : float, pusher : Pushable):
	$Shot.play()
	
	$AnimatedSprite3D.play()
	
	_lastThrower = pusher

	super(dir, factor, pusher)

func _process(_delta):
	$AnimatedSprite3D.modulate = color
	
	if velocity.is_zero_approx():
		$AnimatedSprite3D.stop()

func _on_area_3d_body_entered(body):
	if velocity.is_zero_approx():
		return
	if not body is Monigote or body == _lastThrower:
		return
	
	var monigote := body as Monigote
	monigote.hurt()
	queue_free()
