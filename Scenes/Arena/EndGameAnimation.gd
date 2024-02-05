extends Control

@export var zoomScale : float = 3
## Tiempo entre que alguien gana y se frena el juego
@export var deadTime : float = .8

func startAnimation(winner: Monigote):
	# Hay que tener esta información apenas termina el juego por si se muere el
	# monigote ganador en el tiempo hasta la animación
	var winnerPos = winner.position
	var winnerId = winner.player.id
	
	%HUD.visible = false
	await get_tree().create_timer(deadTime).timeout
	get_tree().paused = true
	
	# Si sigue existiendo el monigote, conseguimos su posición actual
	if is_instance_valid(winner):
		winnerPos = winner.position
		winnerId = winner.player.id
	
	$Background.texture = ImageTexture.create_from_image(
	get_viewport().get_texture().get_image())
	
	%HiResTexture.visible = false
	%LowResContainer.visible = false
	
	var zoomPos = %Arena.getScreenPos(winnerPos)
	zoomPos *= %LowResContainer.stretch_shrink
	
	# Es más fácil hacer el zoom cuando el pivot offset está en el punto al que
	# nos queremos acercar
	$Background.pivot_offset = zoomPos
	
	var tween := create_tween().set_ease(Tween.EASE_OUT)
	
	# Para atrás
	tween.tween_property($Background, "scale", Vector2.ONE * .9, .1)
	# Zoom
	tween.tween_property($Background, "position", $WinnerPoint.position - zoomPos, .2)
	tween.parallel().tween_property($Background, "scale", Vector2.ONE * zoomScale, .2)
	
	# A poner luego en su lugar en la animación
	BetHandler.settleBet(winnerId)
	
	$RoundEnd.setupBoard()
	$RoundEnd.visible = true
