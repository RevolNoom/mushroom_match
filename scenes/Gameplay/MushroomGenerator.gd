extends Node


@onready var mushroom_scn = load("res://scenes/Gameplay/Mushroom/Mushroom.tscn")

@export var gen_set_size = 7
var gen_set: Array[Mushroom]


func _ready():
	RandomizeGeneratingMushroomSet(gen_set_size)


# Return an array of mushrooms with different textures and ids
func RandomizeGeneratingMushroomSet(differrent_mushroom_types: int):
	gen_set.clear()
	var id = 1
	
	mushrooms["unique"].shuffle()
	for i in mushrooms["unique"]:
		var mushroom = mushroom_scn.instantiate()
		mushroom.texture = i
		mushroom.ID = id
		id += 1
		gen_set.append(mushroom)
		
	var mtypes = mushrooms.keys()
	mtypes.erase("unique")
	
	for i in mtypes:
		var mushroom = mushroom_scn.instantiate()
		mushroom.texture = mushrooms[i].pick_random()
		mushroom.ID = id
		id += 1
		gen_set.append(mushroom)
		if gen_set.size() >= differrent_mushroom_types:
			break


func GenerateNewIDs(amount: int) -> PackedInt32Array:
	var result = PackedInt32Array()
	while amount > 0:
		result.append(randi_range(1, gen_set_size))
		amount -= 1
	return result



func GetNewMushroom(id: int):
	return gen_set[id-1].duplicate() #id is 1-based


func GetSaveData():
	var gen_set_textures = []
	for i in gen_set:
		gen_set_textures.push_back(i.texture.resource_path)
	return {
		"path": get_path(),
		"gen_set_textures": gen_set_textures,
		#"textures": mushrooms
		}


func LoadSaveData(save_data: Dictionary):
	for obj in gen_set:
		obj.queue_free()
	gen_set.clear()
	
	for i in range(0, save_data["gen_set_textures"].size()):
		var mushroom = mushroom_scn.instantiate()
		mushroom.texture= load(save_data["gen_set_textures"][i])
		mushroom.ID = i + 1
		gen_set.append(mushroom)


@export var mushrooms: Dictionary = {
	"white": [
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Champignon.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Common_Funnel.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Enoki.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Parasol_Mushroom.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Shaggy_Mane.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Straw_Mushroom.png"),
	],
	
	"gold": [
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Ceasar's_Mushroom.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Chanterelle.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Chicken_of_the_Wood.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Honey_Agaric.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Honey_Fungus.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Lobster_Mushroom.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Penny_Bun.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Shimeji.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Suillus_Luteus.png"),
	],
	
	"grey": [
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Black_Trumpet.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Grey_Knight.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Inky_Cap.png"),
	],
	
	"dark-brown": [
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Greasers.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Maitake.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Truffle.png"),
	],
	
	"light-brown": [
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Matsutake.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Medusa_Mushroom.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Morchella_(True_Morels).png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Saffron_Milkcap.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Shiitake.png"),
	],
	
	"red":[
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Aspen.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Bare-toothed_Russula.png"),
	],
	
	"unique": [
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Golden_Brittlegill.png"),
		load("res://assets/ValleyFriends_Edible_Mushrooms/items/Indigo_Milkcap.png"),
	],
}
