extends TextureButton

class_name Cell

signal chosen(_self)
signal mushroom_on_spore(_self)


var _mushroom: Mushroom
var _spore


func _on_pressed():
	emit_signal("chosen", self)


#TODO: Check if there's mushroom already? Is it necessary?
func AddMushroom(mushroom: Mushroom):
	add_child(mushroom)
	_mushroom = mushroom
	_on_item_rect_changed()


func PopMushroom() -> Mushroom:
	var mushroom = _mushroom
	remove_child(mushroom)
	_mushroom = null
	return mushroom


func IsEmpty():
	return get_child_count() == 0


func HasMushroom():
	return get_child_count() > 0 && get_child(0) is Mushroom
	
	
#TODO: Create Spore
func HasSpore():
	return get_child_count() > 0 && get_child(0) is Sprite2D


func _on_item_rect_changed():
	for child in get_children():
		#var c = child as Sprite2D
		child.scale = size / child.get_rect().size
		child.position = size/2
		#print("cell " + str(name) + ": " + str(position) + " size " + str(size))
		#print("child: " + str(child.position))
