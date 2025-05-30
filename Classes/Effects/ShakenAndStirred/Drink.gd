extends Area3D

@export var drunkTime : float = 1

func _ready():
	$Sprite3D.region_rect.position.x = (randi() % 2) * $Sprite3D.region_rect.size.x
	$Sprite3D.region_rect.position.y = (randi() % 2) * $Sprite3D.region_rect.size.y
	
	var spriteScale = $Sprite3D.scale
	$Sprite3D.scale = Vector3.ZERO
	var scaleTween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	scaleTween.tween_property($Sprite3D, "scale", spriteScale, .5)

func _on_body_entered(body):
	if not body is Monigote:
		return
	
	if body.drunk or body.velocity.y > 0:
		return
	
	body.drunk = true
	get_tree().create_timer(drunkTime).timeout.connect(func(): 
		if is_instance_valid(body):
			body.drunk = false)
