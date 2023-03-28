extends TextureButton

class_name Cell

signal chosen(_self)
signal mushroom_on_spore(_self)


var _mushroom: Mushroom
var _spore


func _on_pressed():
	emit_signal("chosen", self)


#TODO: Check if there's mushroom already? Is it necessary?
func Add(mushroom: Mushroom):
	add_child(mushroom)
	if mushroom._grown:
		pass
		_mushroom = mushroom
	else:
		_spore = mushroom
	_on_item_rect_changed()


func Pop() -> Mushroom:
	var mushroom = get_child(0)
	remove_child(mushroom)
	if mushroom._grown:
		_mushroom = null
	else:
		_spore = null
	return mushroom


func IsEmpty():
	return get_child_count() == 0


func HasMushroom():
	return _mushroom != null
	
	
func HasSpore():
	return _spore != null


func GrowSporeIntoMushroom():
	_spore._grown = true
	_mushroom = _spore
	_spore = null
	_on_item_rect_changed()

func _on_item_rect_changed():
	for child in get_children():
		child.scale = size / child.get_rect().size
		if not child._grown:
			child.scale /= 3
		child.position = size/2
