extends Effect

@export var CardScene : PackedScene

const CARD_HEIGHT = .85 

var running := false

var cards : Array

func _ready():
	$AnimationPlayer.connect("animation_finished", onAnimationEnd)

func start():
	running = true
	startRandomAttack()

func end():
	running = false
	$AnimationPlayer.stop()
	
	for card in cards:
		if is_instance_valid(card):
			card.queue_free()
	cards = []

func onAnimationEnd(_anim):
	await get_tree().create_timer(2).timeout
	startRandomAttack()

func startRandomAttack():
	if (not running) or (not MultiplayerHandler.isAuthority()):
		return
	
	var idx = randi() % ($AnimationPlayer.get_animation_list().size() - 1)
	startAttack.rpc($AnimationPlayer.get_animation_list()[idx])

@rpc("reliable", "call_local", "authority")
func startAttack(animation : String):
	$Startup.play()
	$AnimationPlayer.play(animation)

func createCard(pos : Vector3, dir : Vector3):
	var card : Card = CardScene.instantiate()
	card.position = pos
	card.position.y = CARD_HEIGHT
	card.dir = dir
	arena.add_child(card)
	
	cards.append(card)
