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
		$GrabGraceTime.start()

func onPushed():
	$GrabCooldown.start()
	if mon.grabbing:
		hands.onPush($GrabCooldown.wait_time)
	else:
		hands.goToRest($GrabCooldown.wait_time)

func onMonigoteGrabbed():
	mon.escapeMovements = 0
	mon.invincible = true

func onGrabGraceTimeTimeout():
	if not mon.grabbing:
		onPushed()

func onGrabAreaBodyEntered(body):
	if $GrabGraceTime.is_stopped() or not body is Pushable:
		return
	
	if mon.startGrab(body):
		mon.emit_signal("grab", body)
