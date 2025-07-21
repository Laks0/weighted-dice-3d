extends Effect

@export var drinkScene : PackedScene
@export var drunkParticlesScene : PackedScene
@export var drinksAmount : int = 1

var drinks : Array[ShakenAndStirredDrink]
var particlesArray : Array[GPUParticles3D]

func start():
	for _i in range(drinksAmount):
		var drink = drinkScene.instantiate()
		drink.position = arena.getRandomPosition()
		arena.add_child(drink)
		drinks.append(drink)
	
	for mon : Monigote in arena.getLivingMonigotes():
		var particles : GPUParticles3D = drunkParticlesScene.instantiate()
		for drink in drinks:
			drink.monigoteGotDrunk.connect(func (drunkMonigote : Monigote):
				if drunkMonigote == mon:
					particles.emitting = true)
			drink.monigoteGotSober.connect(func (drunkMonigote : Monigote):
				if drunkMonigote == mon:
					particles.emitting = false)
		
		mon.get_node("AnimatedSprite").add_child(particles)
		particlesArray.append(particles)

func end():
	for drink in get_tree().get_nodes_in_group("Drinks"):
		drink.queue_free()
	for particles in particlesArray:
		if is_instance_valid(particles):
			particles.queue_free()
	drinks.clear()
	particlesArray.clear()
	for mon in get_tree().get_nodes_in_group("Monigotes"):
		mon.drunk = false
