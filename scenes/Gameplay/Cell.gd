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
	add_child(mushroom)
	mushroom.name = mush_name
	_on_item_rect_changed()


func PopMushroom() -> Mushroom:
	return Pop("Mushroom")
func PopSpore() -> Mushroom:
	return Pop("Spore")
func Pop(type: String) -> Mushroom:
	var mushroom = get_node(type)
	remove_child(mushroom)
	return mushroom


func GetMushroom() -> Mushroom:
	return Get("Mushroom")
func GetSpore() -> Mushroom:
	return Get("Spore")
func Get(type: String) -> Mushroom:
	return get_node_or_null(type)
	

func IsEmpty() -> bool:
	return get_child_count() == 0


func HasMushroom() -> bool:
	return get_node_or_null("Mushroom") != null
	
	
func HasSpore() -> bool:
	return  get_node_or_null("Spore") != null


func GrowSporeIntoMushroom():
	get_node("Spore")._grown = true
	get_node("Spore").name = "Mushroom"
	_on_item_rect_changed()

func _on_item_rect_changed():
	for child in get_children():
		child.scale = size / child.get_rect().size
		if not child._grown:
			child.scale /= 3
		child.position = size/2
