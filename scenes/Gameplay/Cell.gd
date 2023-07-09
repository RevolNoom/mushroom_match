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
	mushroom.connect("state_changed", _on_mushroom_state_changed)


func _on_mushroom_state_changed(mushroom: Mushroom, is_spore: bool):
	mushroom.get_parent().remove_child(mushroom)
	if is_spore:
		$Center/Spore.add_child(mushroom)
	else:
		$Center/Mushroom.add_child(mushroom)


func Clear():
	if HasSpore():
		#print("PopSpore()")
		PopSpore().queue_free()
	if HasMushroom():
		#print("PopMushroom()")
		PopMushroom().queue_free()


func GetMushroom() -> Mushroom:
	return $Center/Mushroom.get_child(0)
func GetSpore() -> Mushroom:
	return $Center/Spore.get_child(0)
	

func PopMushroom() -> Mushroom:
	var mushroom = $Center/Mushroom.get_child(0)
	$Center/Mushroom.remove_child(mushroom)
	mushroom.disconnect("state_changed", _on_mushroom_state_changed)
	return mushroom


func PopSpore() -> Mushroom:
	var spore = $Center/Spore.get_child(0)
	$Center/Spore.remove_child(spore)
	spore.disconnect("state_changed", _on_mushroom_state_changed)
	return spore


func IsEmpty() -> bool:
	return not (HasMushroom() or HasSpore())


func HasMushroom() -> bool:
	return $Center/Mushroom.get_child_count()

func HasSpore() -> bool:
	return $Center/Spore.get_child_count()

func center_position():
	return $Center.global_position
	
	
var MushroomTextureSize = Vector2(16, 16)
func _on_item_rect_changed():
	$Center.scale = size / MushroomTextureSize
