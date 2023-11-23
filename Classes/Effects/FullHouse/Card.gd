extends Area3D
class_name Card

var dir : Vector3 = Vector3.FORWARD
@onready var positionTween : Tween = get_tree().create_tween()
@onready var rotationTween : Tween = get_tree().create_tween()

func _ready():
	look_at(position + dir)
	$Warning.position = Vector3.FORWARD * 2.5
	
	var arena : Arena
	var finalPos : Vector3
	positionTween.tween_property(self, "position", 
		Vector3(position.x + arena.WIDTH * dir.x, 
			position.y, 
			position.y + arena.HEIGHT * dir.z), 
		2)
	positionTween.set_ease(Tween.EASE_IN)
	positionTween.stop()
	positionTween.connect("finished", kill)
	
	rotationTween.tween_property($PokerCardHeart, "rotation", Vector3(0, 0, PI/15), .2)
	rotationTween.chain().tween_property($PokerCardHeart, "rotation", Vector3(0, 0, -PI/15), .2)
	rotationTween.set_ease(Tween.EASE_IN_OUT)
	rotationTween.set_loops()
	rotationTween.stop()

func shoot():
	$Warning.visible = false
	
	positionTween.play()
	rotationTween.play()

func kill():
	positionTween.kill()
	rotationTween.kill()
	queue_free()

func _on_body_entered(body):
	if not body is Monigote:
		return
	var mon := body as Monigote
	
	var knockSpeed = 15
	var dir = position.direction_to(mon.position)
	mon.knockback(Vector2(dir.x, dir.z).normalized() * knockSpeed)
	mon.hurt()
