extends TextureButton

class_name Cell

signal chosen(_self)
#signal grow_anim_finish


func _on_pressed():
	#print("pressed " + name)
	emit_signal("chosen", self)


func AddMushroom(mushroom: Mushroom):
	Add(mushroom, "Mushroom")
	#mushroom.z_index = 1
	
func AddSpore(mushroom: Mushroom):
	mushroom.scale = Vector2()
	Add(mushroom, "Spore")
	mushroom.PlayAnim("sprout")
	
func Add(mushroom: Mushroom, type: String):
	#print(name + " Added " + type)#("Yes" if has else "No"))
	$Center.add_child(mushroom)
	mushroom.name = type
	mushroom.position = Vector2()


func PopMushroom() -> Mushroom:
	return Pop("Mushroom")
func PopSpore() -> Mushroom:
	return Pop("Spore")
func Pop(type: String) -> Mushroom:
	var mushroom = $Center.get_node(type)
	$Center.remove_child(mushroom)
	return mushroom


func Clear():
	if not IsEmpty():
		if HasSpore():
			PopSpore().queue_free()
		else:
			PopMushroom().queue_free()


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
	$Center.get_node("Spore").PlayAnim("grow")
	#$Center.get_node("Spore").z_index = 1
	$Center.get_node("Spore").name = "Mushroom"
	

var MushroomTextureSize = Vector2(16, 16)
func _on_item_rect_changed():
	$Center.scale = size / MushroomTextureSize
	$Center.global_position = global_position + size / 2
