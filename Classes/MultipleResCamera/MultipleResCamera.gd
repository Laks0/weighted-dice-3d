extends Camera3D

func _process(_delta):
	%HiResCamera.position = position
	%HiResCamera.rotation = rotation
	
	%LowResCamera.position = position
	%LowResCamera.rotation = rotation
	
	%FullCamera.position = position
	%FullCamera.rotation = rotation

func getHiResTexture() -> ViewportTexture:
	return $HiResViewport.get_texture()

func getLowResTexture() -> ViewportTexture:
	return $LowResViewport.get_texture()

func getFullTexture() -> ViewportTexture:
	return $FullViewport.get_texture()
