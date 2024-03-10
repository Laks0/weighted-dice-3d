extends RigidBody3D

var id : int

@export var monigoteTextures : Array[Texture]

func _ready():
	id = randi() % 6

func _process(_delta):
	$Pelotita/PelotaGacha_001.material_override.albedo_color = PlayerHandler.getSkinColor(id)

func startAnimation():
	$MonigoteSprite.texture = monigoteTextures[id]
	$PlayerName.text = PlayerHandler.getSkinName(id)
	$PlayerName.modulate = PlayerHandler.getSkinColor(id)
	
	$MonigoteSprite.visible = true
	var spriteTween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	var finalScale = $MonigoteSprite.scale
	$MonigoteSprite.scale = Vector3.ZERO
	spriteTween.tween_property($MonigoteSprite, "scale", finalScale, .6)
	
	$Pelotita/AnimationPlayer.play("PelotaGachaAction_001")
	await $Pelotita/AnimationPlayer.animation_finished
	$PlayerName.visible = true
