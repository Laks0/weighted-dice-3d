extends Node

const SPRITE_HEIGHT := .325 # La altura y a la que se spawnean los objetos con sprite

# Rectángulo de la arena
const TOP_CORNER    := Vector3(-5.5, 0, -2.5)
const BOTTOM_CORNER := Vector3(5.5, 0, 2.5)

func getRandomArenaPosition() -> Vector3:
	return Vector3(randf_range(TOP_CORNER.x, BOTTOM_CORNER.x), SPRITE_HEIGHT,
			randf_range(TOP_CORNER.z, BOTTOM_CORNER.z))
