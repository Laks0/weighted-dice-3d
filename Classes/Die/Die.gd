extends RigidBody3D
class_name Die

@warning_ignore("unused_signal")
signal rolled(n)
## Se llama cuando el dado se subió al cubilete
@warning_ignore("unused_signal")
signal onCubilete
## Se llama cuando el cubilete suelta el dado
@warning_ignore("unused_signal")
signal dropped

@onready var rotations : DieRotations = $Rotations

## La velocidad mínima que necesita el dado para poder herir a un monigote
@export var minMovementToHurt : float = .1
## El tiempo que espera después de rollear para atacar
@export var timeAfterRoll : float = 1.4

## Si esta variable es n, la chance de sacar un 6 es 1/n
@export var invertedChanceOfSix : int = 8

@export var numberLightPosition : float = 2

var hitting := false

func _ready():
	visible = false

func _physics_process(_delta: float) -> void:
	$StompParticles.global_position = global_position
	$ExpansiveParticles.global_position = global_position

func throw(impulse : Vector3):
	apply_central_impulse(impulse)
	var torque := Vector3(randf(), randf(), randf()).normalized()
	apply_torque_impulse(torque * 10)

func onFloor() -> bool:
	for body in get_colliding_bodies():
		if body.is_in_group("Table"):
			return true
	return false

func disableCollision():
	$Area3D.monitoring = false
	$CollisionShape3D.disabled = true

func enableCollision():
	$Area3D.monitoring = true
	$CollisionShape3D.disabled = false

func _getRandomMonigoteDirection() -> Vector2:
	var monigote : Monigote = get_parent().getRandomMonigote()
	if not is_instance_valid(monigote):
		return Vector2.LEFT
	
	var dir3d : Vector3 = global_position.direction_to(monigote.global_position)
	
	return Vector2(dir3d.x, dir3d.z).normalized()

func _getClosestMonigoteDirection() -> Vector2:
	if not is_instance_valid(get_parent().getClosestMonigote(position)):
		return Vector2.LEFT
	
	var closestMonigotePos = get_parent().getClosestMonigote(position).position
	var dir3d = position.direction_to(closestMonigotePos)
	return Vector2(dir3d.x, dir3d.z)

func _on_area_3d_body_entered(body):
	if not visible:
		return
	if linear_velocity.length() < minMovementToHurt and not hitting:
		return
	
	if body is Monigote:
		$SoundManager.playSplat() #Esto está mal en realidad, debería solo sonar cuando el monigote es aplastado
		body.hurt()
		body.movement.applyVelocity(Vector2(linear_velocity.x, linear_velocity.z) * 2)

## Los pesos de cada efecto hasta el 5
var effectOdds : Array[float] = [.2, .2, .2, .2, .2]
## La probabilidad que se agrega cuando un efecto no es elegido
var notChosenBonus := .05
var _timesRolled = 0

func pickNewEffect(oldEffect : int) -> int:
	_timesRolled += 1
	
	if Debug.vars.onlyEffect != "":
		return Debug.vars.onlyEffectNumber
	
	var result = oldEffect
	var ceiling : float = effectOdds.reduce(func (accum, val): return accum + val)
	while result == oldEffect:
		# El efecto 6 solo puede salir a partir del tercer efecto
		if _timesRolled > 3 and randf() < 1.0/invertedChanceOfSix:
			result = 5
			continue
		
		# Elección pesada
		var pickedNumber := randf_range(0, ceiling)
		var sum := 0.0
		for i in range(5):
			sum += effectOdds[i]
			if pickedNumber <= sum:
				result = i
				break
	
	# Ajuste de pesos
	for i in range(5):
		if result == i:
			effectOdds[i] = .2
		else:
			effectOdds[i] += notChosenBonus
	
	return result

func _onCurrentEffectFinished():
	$BehaviourHandler._onCurrentEffectFinished()

func _onEffectStarted(effect : Effect):
	$BehaviourHandler._onEffectStarted(effect)

func stompAnimation():
	$ExpansiveParticles.restart()
	$StompParticles.restart()
