extends Control

@export var zoomScale : float = 3

func startAnimation(winner: Monigote):
	$Background.texture = ImageTexture.create_from_image(
	get_viewport().get_texture().get_image())
	
	%HiResTexture.visible = false
	%LowResContainer.visible = false
	%HUD.visible = false
	
	var zoomPos = %Arena.getScreenPos(winner.position)
	zoomPos *= %LowResContainer.stretch_shrink
	
	# Es más fácil hacer el zoom cuando el pivot offset está en el punto al que
	# nos queremos acercar
	$Background.pivot_offset = zoomPos
	
	var tween := create_tween().set_ease(Tween.EASE_OUT)
	
	tween.tween_property($Background, "scale", Vector2.ONE * .9, .1)
	tween.tween_property($Background, "position", $WinnerPoint.position - zoomPos, .2)
	tween.parallel().tween_property($Background, "scale", Vector2.ONE * zoomScale, .2)
	
	# A poner luego en su lugar en la animación
	BetHandler.settleBet(winner.player.id)
	
	$RoundEnd.setupBoard()
	$RoundEnd.visible = true
