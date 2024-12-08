## El script interactua con la API de Pushable del monigote, sus funciones se siguen teniendo que
## llamar desde Monigote
extends Node3D

@onready var mon : Monigote = get_parent()
@export var hands : Node3D

func _physics_process(_delta):
	var pointing := Controllers.getDirection(mon.controller)
	if pointing != Vector2.ZERO:
			mon.grabDir = pointing
			$GrabArea.rotation.y = -pointing.angle()

func canBeGrabbed(grabber):
	return (mon != grabber) and (not mon.invincible)

func canGrab():
	return $GrabCooldown.is_stopped() and (not mon.grabbed) and (not mon.grabbing)

func attemptGrab():
	if not $GrabCooldown.is_stopped():
		return
	
	hands.attack($GrabReadyTime.wait_time)
	$GrabReadyTime.start()
	await $GrabReadyTime.timeout
	if not Input.is_action_pressed(mon.actions["grab"]):
		onPushed()
		return
	
	var couldGrab := false
	for body in $GrabArea.get_overlapping_bodies():
		if not body is Pushable or body == self:
			continue
		
		var success : bool = mon.startGrab(body)
		if !success:
			continue
		
		couldGrab = true
		mon.emit_signal("grab", body)
		break
	
	if not couldGrab:
		onPushed()

func onPushed():
	$GrabCooldown.start()
	hands.go_to_rest($GrabCooldown.wait_time)

func onGrabbed():
	mon.escapeMovements = 0
	mon.invincible = true
