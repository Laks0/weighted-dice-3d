extends WorldEnvironment

@export var controllingLights : Array[Light3D]

func fogOn(density : float = .01, time : float = .5):
	environment.volumetric_fog_enabled = true
	var tween := get_tree().create_tween()
	tween.tween_property(environment, "volumetric_fog_density", density, time)

func fogOff(time : float = .5):
	var tween := get_tree().create_tween()
	tween.tween_property(environment, "volumetric_fog_density", 0, time)

func lightsOff():
	var lightTween := get_tree().create_tween().parallel()
	for l in controllingLights:
		lightTween.tween_property(l, "light_energy", .3, 1)
	$GlobalLight.visible = false
	lightTween.set_ease(Tween.EASE_OUT)

func lightsOn():
	var lightTween := get_tree().create_tween().parallel()
	for l in controllingLights:
		lightTween.tween_property(l, "light_energy", 1, 1)
	$GlobalLight.visible = true
	lightTween.set_ease(Tween.EASE_OUT)
