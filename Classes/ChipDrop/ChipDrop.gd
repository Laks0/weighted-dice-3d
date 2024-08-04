extends Node3D

signal pickedUp(playerId : int)

@export var bonus : int = 2

var animationLenght := .5
var appeared := false

var colorTween : Tween
var heightTween : Tween

func _ready():
	$FichaMesh/Label3D.text = str(bonus)
	
	create_tween().tween_property(self, "scale", scale, animationLenght)\
		.from(Vector3.ZERO)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(animationLenght).timeout
	
	$FichaMesh/Label3D.visible = true
	
	# Hue
	var hueWheelTime := 3
	colorTween = create_tween().set_loops()
	colorTween.tween_property($FichaMesh, "surface_material_override/0:albedo_color:h", 350, hueWheelTime)\
		.from(0)
	# Altura de la ficha
	heightTween = create_tween().set_loops()
	heightTween.tween_property($FichaMesh, "position:y", .2, .7).as_relative()
	heightTween.tween_property($FichaMesh, "position:y", -.2, .7).as_relative()
	heightTween.set_ease(Tween.EASE_IN_OUT)
	heightTween.set_trans(Tween.TRANS_QUAD)
	
	appeared = true

func _on_area_3d_body_entered(body):
	if (not appeared) or (not body is Monigote):
		return
	
	var mon := body as Monigote
	pickedUp.emit(mon.player.id)
	appeared = false
	$AudioStreamPlayer.play()
	
	colorTween.stop()
	$FichaMesh.get_surface_override_material(0).albedo_color = mon.player.color
	mon.player.setRoundBonus(bonus)
	
	create_tween().tween_property(self, "scale", Vector3.ZERO, animationLenght)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_IN)\
		.finished.connect(queue_free)

func disable():
	$Area3D.monitoring = false
	# Por si no se creó todavía el heightTween
	while not is_instance_valid(heightTween):
		await get_tree().process_frame
	heightTween.stop()
