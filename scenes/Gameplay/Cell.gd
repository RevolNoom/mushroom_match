extends TextureButton

class_name Cell

signal chosen(_self)


func _on_pressed():
	emit_signal("chosen", self)


#TODO: Check if there's mushroom already? Is it necessary?
func AddMushroom(mushroom: Mushroom):
	Add(mushroom, "Mushroom")
func AddSpore(mushroom: Mushroom):
	Add(mushroom, "Spore")
func Add(mushroom: Mushroom, mush_name: String):
	$Center.add_child(mushroom)
	mushroom.name = mush_name


func PopMushroom() -> Mushroom:
	return Pop("Mushroom")
func PopSpore() -> Mushroom:
	return Pop("Spore")
func Pop(type: String) -> Mushroom:
	var mushroom = $Center.get_node(type)
	$Center.remove_child(mushroom)
	return mushroom


func GetMushroom() -> Mushroom:
	return Get("Mushroom")
func GetSpore() -> Mushroom:
	return Get("Spore")
func Get(type: String) -> Mushroom:
	return $Center.get_node_or_null(type)
	

func IsEmpty() -> bool:
	return $Center.get_child_count() == 0


func HasMushroom() -> bool:
	return $Center.get_node_or_null("Mushroom") != null
func HasSpore() -> bool:
	return $Center.get_node_or_null("Spore") != null


func GrowSporeIntoMushroom():
	$Center.get_node("Spore")._grown = true
	$Center.get_node("Spore").name = "Mushroom"
	GetMushroom().scale = Vector2(1, 1)
	

var MushroomTextureSize = Vector2(16, 16)
func _on_item_rect_changed():
	$Center.scale = size / MushroomTextureSize
	$Center.global_position = global_position + size / 2
