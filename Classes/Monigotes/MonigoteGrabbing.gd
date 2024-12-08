## El script interactua con la API de Pushable del monigote, sus funciones se siguen teniendo que
## llamar desde Monigote
extends Node3D

@onready var mon : Monigote = get_parent()

func _physics_process(delta):
	var pointing := Controllers.getDirection(mon.controller)
	if pointing != Vector2.ZERO:
			$GrabArea.rotation.y = -pointing.angle()

func canBeGrabbed(grabber):
	return (mon != grabber) and (not mon.invincible)

func canGrab():
	return $GrabCooldown.is_stopped() and (not mon.grabbed) and (not mon.grabbing)

func attemptGrab():
	for body in $GrabArea.get_overlapping_bodies():
		if not body is Pushable or body == self:
			continue
		
		var success : bool = mon.startGrab(body)
		if !success:
			continue
		
		$GrabCooldown.start()
		mon.emit_signal("grab", body)
		break

func onGrabbing():
	var pointing := Controllers.getDirection(mon.controller)
	if pointing != Vector2.ZERO:
			mon.grabDir = pointing

func onGrabbed():
	mon.escapeMovements = 0
	mon.invincible = true
