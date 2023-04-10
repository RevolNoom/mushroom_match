extends Node


@onready var mushroom_scn = load("res://scenes/Gameplay/Mushroom/Mushroom.tscn")
@export var mushrooms: Array[Texture]

var gen_set: Array[Mushroom]

# Return an array of mushrooms with different textures and ids
func RandomizeGeneratingMushroomSet(differrent_mushroom_types: int):
	gen_set.clear()
	mushrooms.shuffle()
	for i in range(0, differrent_mushroom_types):
		var mushroom = mushroom_scn.instantiate()
		mushroom.texture = mushrooms[i]
		mushroom.ID = i + 1
		gen_set.append(mushroom)


func GenerateMushrooms(amount: int) -> Array[Mushroom]:
	var result: Array[Mushroom] = []
	for i in range(0, amount):
		result.append(gen_set.pick_random().duplicate())
	return result


