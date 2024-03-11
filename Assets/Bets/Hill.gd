extends Sprite3D

func _ready():
	var alphaTween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	alphaTween.tween_property(self, "modulate:a", .5, .5)
	alphaTween.tween_property(self, "modulate:a", 1, .5)
	
	await get_tree().create_timer(3).timeout
	$Label3D.visible = false
