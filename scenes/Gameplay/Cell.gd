extends TextureButton

class_name Cell

signal chosen(_self)


func _on_pressed():
	emit_signal("chosen", self)


func Add(mushroom: Mushroom):
	if mushroom.IsSpore():
		$Center/Spore.add_child(mushroom)
	else:
		$Center/Mushroom.add_child(mushroom)
	mushroom.position = Vector2()
	mushroom.connect("ungrown", _on_mushroom_ungrown)
	mushroom.connect("grown", _on_mushroom_ungrown)
	mushroom.connect("popped", _on_mushroom_popped)


func _on_mushroom_ungrown(mushroom):
	mushroom.get_parent().remove_child(mushroom)
	$Center/Spore.add_child(mushroom)
	
	
func _on_mushroom_grown(mushroom):
	mushroom.get_parent().remove_child(mushroom)
	$Center/Mushroom.add_child(mushroom)


# TODO: Disconnect signals then delete it?
func _on_mushroom_popped(mushroom):
	pass
	#mushroom.get_parent().remove_child(mushroom)
	#$Center/Mushroom.add_child(mushroom)



func Clear():
	if HasSpore():
		GetSpore().Pop()
	elif HasMushroom():
		GetMushroom().Pop()


func GetMushroom() -> Mushroom:
	return $Center/Mushroom.get_child(0)
func GetSpore() -> Mushroom:
	return $Center/Spore.get_child(0)
	

func PopMushroom() -> Mushroom:
	return $Center/Mushroom.get_child(0)
func PopSpore() -> Mushroom:
	return $Center/Spore.get_child(0)
	
func IsEmpty() -> bool:
	return not (HasMushroom() or HasSpore())


func HasMushroom() -> bool:
	return $Center/Mushroom.get_child_count()
func HasSpore() -> bool:
	return $Center/Spore.get_child_count()


var MushroomTextureSize = Vector2(16, 16)
func _on_item_rect_changed():
	$Center.scale = size / MushroomTextureSize
	$Center.global_position = global_position + size / 2
