extends Control

func _process(_delta):
	$HiResTexture.texture = %Arena.getHiResTexture()
	$HiResTexture.material.set_shader_parameter("fullTexture", %Arena.getFullTexture())
	$HiResTexture.material.set_shader_parameter("lowTexture", %Arena.getLowResTexture())
