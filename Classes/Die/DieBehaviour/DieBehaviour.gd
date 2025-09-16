extends AnimationStep
class_name DieBehaviourStep

var die : Die

func setDie(parentDie : Die):
	die = parentDie

func start():
	if animationRoot() is DieBehaviourStep:
		die = animationRoot().die
	super()
