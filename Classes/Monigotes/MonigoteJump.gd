extends Node3D

var jumping := false
@onready var mon : Monigote = get_parent()
@export var JUMP_SPEED : float = 7

func _process(_delta):
	if Input.is_action_just_pressed(mon.actions.jump):
		jump()

func jump():
	if jumping or not $JumpCooldown.is_stopped():
		return
	
	mon.disable_steer()
	mon.velocity.y = JUMP_SPEED
	jumping = true

func onFloorCollision(body):
	if mon.velocity.y > 0 or not jumping:
		return
	
	if body is StaticBody3D:
		jumping = false
		$JumpCooldown.start()
		mon.enable_steer()
	
	if body is Monigote:
		jumping = false
		$JumpCooldown.start()
		body.knockback(Vector2.DOWN * 8)
		mon.knockback(Vector2.UP * 8)
		mon.enable_steer()
