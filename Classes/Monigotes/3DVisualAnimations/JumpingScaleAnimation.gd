extends MonigoteAnimation3D

@export_range(0,1) var squashHeight := .8
@export_range(0,.1) var strechFactor := .04

func physicsUpdate(_delta):
	resultBasis.y.y = 1 + max(0,mon.velocity.y*strechFactor)

func stop():
	var tween := create_tween()
	tween.tween_property(self, "resultBasis:y:y", squashHeight, .05)
	tween.tween_property(self, "resultBasis:y:y", 1, .05)
	await tween.finished
	super()
