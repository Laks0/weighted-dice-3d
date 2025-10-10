extends Sprite3D

func setBindingOnControllersAction(actionName : String, controllerId: int) -> void:
	$SubViewport/InputDisplayTexture.setBindingOnControllersAction(actionName, controllerId)
