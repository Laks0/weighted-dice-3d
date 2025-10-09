extends Node3D

@export var numberOfSprites : int = 12

@export_category("Scene nodes")
@export var ruedas : Array[MeshInstance3D]
@export var slotAnimation : AnimationPlayer

var test := preload("res://Autoload/Bets/KingOfTheHill.gd").new()

func _ready() -> void:
	_createSprites()
	#setDisplayBet(test)
	#startAnimation($MultipleResCamera)

func _createSprites():
	for rueda : MeshInstance3D in ruedas:
		var winnerSprite : Sprite3D = rueda.get_node("WinnerSprite")
		for i in range(1,numberOfSprites):
			var s := winnerSprite.duplicate()
			rueda.add_child(s)
			var spriteRotation : float = i*2*PI/numberOfSprites
			s.rotate_x(spriteRotation)
			s.position = s.position.rotated(Vector3.RIGHT, spriteRotation)

func setDisplayBet(newBet : Bet):
	$TragaMonedas_INT_v2/Hoja/SubViewport/BetSheetDisplay.setBetToDisplay(newBet)
	for i in range(ruedas.size()):
		var rueda := ruedas[i]
		
		for sprite in rueda.get_children():
			sprite.texture = BetHandler.getRandomBet().getSlotWheelImage(i)
		
		var winnerSprite : Sprite3D = rueda.get_node("WinnerSprite")
		winnerSprite.texture = newBet.getSlotWheelImage(i)

func startAnimation(camera : MultipleResCamera):
	await camera.goToCamera($FullViewCamera).finished
	
	slotAnimation.play("Animation")
	
	await get_tree().create_timer(.5).timeout
	camera.goToCamera($CloseUpCamera, .25)
	
	await get_tree().create_timer(2.7).timeout
	slotAnimation.pause()
	
	await camera.goToCamera($FullViewCamera).finished
	
	
	await get_tree().create_timer(.5).timeout
	slotAnimation.play()
	
	if slotAnimation.is_playing():
		await slotAnimation.animation_finished
	
	await _betSheetAnimation(camera)

func _betSheetAnimation(camera : MultipleResCamera):
	var sheet = $TragaMonedas_INT_v2/Hoja
	
	var tween := create_tween()
	tween.tween_property(sheet, "global_position", camera.to_global(Vector3.FORWARD * 1.1), .3)
	tween.parallel().tween_property(sheet, "rotation:x", -PI/2, .3)
	
	await tween.finished
	$TragaMonedas_INT_v2/Hoja/SubViewport/BetSheetDisplay.restartVideoGuide()
