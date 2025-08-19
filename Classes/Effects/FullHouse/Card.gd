extends Area3D
class_name Card

var dir : Vector3 = Vector3.FORWARD
@onready var positionTween : Tween = get_tree().create_tween()
@onready var rotationTween : Tween = get_tree().create_tween()

@export var materials : Array[StandardMaterial3D]
@export var introTime : float = 2
@export var heightIntroOffset : float = 4
@export var zIntroOffset : float = 3

func _ready():
	$Mesh/Plane.set_surface_override_material(0, materials.pick_random())
	
	look_at(position + dir)
	$Warning.position = Vector3.FORWARD * 2.5
	
	positionTween.tween_property(self, "position", 
		Vector3(position.x + (Arena.WIDTH + 2) * dir.x, 
			position.y,
			position.y + Arena.HEIGHT * dir.z), 
		1.5)
	positionTween.set_ease(Tween.EASE_IN)
	positionTween.stop()
	positionTween.connect("finished", kill)
	
	rotationTween.tween_property($Mesh, "rotation", Vector3(0, 0, PI/10), .2)
	rotationTween.chain().tween_property($Mesh, "rotation", Vector3(0, 0, -PI/10), .2)
	rotationTween.set_ease(Tween.EASE_IN_OUT)
	rotationTween.set_loops()
	rotationTween.stop()
	
	######################
	# Animación de entrada
	######################
	$Mesh.position = Vector3(0,heightIntroOffset,zIntroOffset)
	$Mesh.rotation.x = -PI/2
	$Mesh.visible = true
	var introTween = create_tween()
	introTween.tween_interval(introTime/2)
	introTween.tween_property($Mesh, "position", Vector3.ZERO, introTime/2)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	introTween.parallel().tween_property($Mesh, "rotation:x", 0, introTime/2)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	introTween.tween_callback(shoot)

func shoot():
	$Warning.visible = false
	
	positionTween.play()
	rotationTween.play()

func kill():
	positionTween.kill()
	rotationTween.kill()
	$CollisionShape3D.disabled = true
	
	#####################
	# Animación de salida
	#####################
	var outroTween = create_tween()
	outroTween.tween_property($Mesh, "position", Vector3(0,heightIntroOffset,-zIntroOffset-2), introTime/2)
	outroTween.parallel().tween_property($Mesh, "rotation:x", PI/4, introTime/2)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	outroTween.tween_callback(queue_free)

func _on_body_entered(body):
	if not body is Monigote:
		return
	var mon := body as Monigote
	
	var knockSpeed = 15
	var knockDir = position.direction_to(mon.position)
	mon.movement.applyVelocity(Vector2(knockDir.x, knockDir.z).normalized() * knockSpeed)
	mon.hurt()
