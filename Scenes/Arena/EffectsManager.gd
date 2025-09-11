extends Node

## Efectos que van en los números del 1 al 5
@export var regularEffects : Array[PackedScene]
## Efectos que van en el 6
@export var specialEffects : Array[PackedScene]

signal effectStarted(effect : Effect)

signal currentEffectFinished

var activeEffect : int

func pickEffects():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	var pickedEffects : Array[PackedScene] = []
	for _i in range(5):
		var pickedEffect : PackedScene = regularEffects.pick_random()
		while pickedEffects.has(pickedEffect):
			pickedEffect = regularEffects.pick_random()
		pickedEffects.append(pickedEffect)
	
	pickedEffects.append(specialEffects.pick_random())
	
	if Debug.vars.onlyEffect != "":
		var effectScene = load(Debug.vars.onlyEffect)
		pickedEffects[Debug.vars.onlyEffectNumber] = effectScene
	
	for i in range(6):
		var effect : Effect = pickedEffects[i].instantiate()
		
		effect.effectFinished.connect(func ():
			if activeEffect == i:
				currentEffectFinished.emit())
		
		add_child(effect)

func startEffect(n : int):
	activeEffect = n
	Narrator.announceEffect(get_child(activeEffect).effectName)

	if n == 5:
		get_parent().environment.lightsOff()

	await get_tree().create_timer(1).timeout

	get_child(activeEffect).start()
	effectStarted.emit(get_child(n))

func stopActiveEffect():
	get_child(activeEffect).end()
	get_parent().environment.lightsOn()
	activeEffect = -1

func _process(delta):
	if get_parent().currentStage() != StageHandler.Stages.ARENA:
		return

	if activeEffect != -1:
		get_child(activeEffect).update(delta)

func getCurrentEffect() -> Effect:
	return getEffect(activeEffect)

func getEffect(n : int) -> Effect:
	return get_child(n)
