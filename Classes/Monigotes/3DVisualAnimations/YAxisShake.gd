extends MonigoteAnimation3D

@export var maxRotation : float = PI/4
var rotationAngle := .0

var tween : Tween

func play():
	tween = create_tween().set_loops()
	tween.tween_property(self, "rotationAngle", maxRotation, .1)
	tween.tween_property(self, "rotationAngle", -maxRotation, .1)
	super()

func physicsUpdate(_delta):
	resultBasis = Basis.from_euler(Vector3(0,rotationAngle,0))

func stop():
	if is_instance_valid(tween):
		tween.stop()
	super()
