extends Control

func _ready():
	%Arena.connect("gameEnded", $EndGameAnimation.startAnimation)
	%Arena.connect("gameEnded", endGame)

func _process(_delta):
	%HiResTexture.texture = %Arena.getHiResTexture()
	%HiResTexture.material.set_shader_parameter("fullTexture", %Arena.getFullTexture())
	%HiResTexture.material.set_shader_parameter("lowTexture", %Arena.getLowResTexture())

func endGame(_winner : Monigote):
	get_tree().paused = true
