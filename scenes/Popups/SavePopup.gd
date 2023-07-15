extends PanelContainer

class_name SavePopup

signal game_loaded(save_data: Dictionary)

# This export is a shortcut for Main menu's Continue
@export var DirectLoadOnPress = false
@export var disable_saving = false:
	set(value):
		disable_saving = value
		$H/V/Content/VBox/ARC/V/SaveNotice.visible = not disable_saving


var slot_filename: Array = []


func _ready():
	refresh_info()


# Return current index in savefile_path
# which is 1-unit less than shown on UI
func current_slot():
	return int($H/V/Content/VBox/HBox/HBox/Current.text) - 1


func refresh_info():
	refresh_savefile_list()
	refresh_ui()


func refresh_ui():
	if current_slot() >= slot_filename.size():
		$H/V/Content/VBox/ARC/MC.hide()
		$H/V/Content/Delete.hide()
		return
		
	$H/V/Content/VBox/ARC/MC.show()
	$H/V/Content/Delete.show()
	
	var savedata = get_slot_json(current_slot())
	var date = savedata["date"]
	$H/V/Content/VBox/ARC/MC/Board/VBox/Date.text =\
		"Date: " + ("0" if date["day"] < 10 else "") + str(date["day"]) + "-"\
				+ ("0" if date["month"] < 10 else "") + str(date["month"]) + "-"\
				+ str(date["year"]) + " "\
				+ ("0" if date["hour"] < 10 else "") + str(date["hour"]) + ":"\
				+ ("0" if date["minute"] < 10 else "") + str(date["minute"])
				
	$H/V/Content/VBox/ARC/MC/Board/VBox/Score.text = "Score: " + savedata["gameplay"]["score"]
	$H/V/Content/VBox/ARC/MC/Board/VBox/Gametime.text = "Gametime: " + savedata["gameplay"]["time_elapsed"]
	$H/V/Content/VBox/ARC/MC/Board.LoadSaveData(savedata["board"])
	


func refresh_savefile_list():
	slot_filename.clear()
	var dir = DirAccess.open("user://")
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		if file.begins_with("save"):
			slot_filename.append(file)

	$H/V/Content/VBox/HBox/HBox/Max.text = str(slot_filename.size() + 1)
	dir.list_dir_end()


# Return a dictionary, that's parsed json in the form: 
# {
# "type1": {keys: attributes},
# "type2": {keys: attributes},
#	...
# }
func get_slot_json(slot: int):
	if slot != clamp(slot, 0, slot_filename.size()-1):
		return null
	
	var savefile = FileAccess.open("user://" + slot_filename[slot], FileAccess.READ)
	if savefile == null:
		print(FileAccess.get_open_error())
		return null
	
	var return_result = JSON.parse_string(savefile.get_line())
	
	savefile.close()
	return return_result


func delete(slot: int):
	DirAccess.remove_absolute("user://" + slot_filename[slot])
	slot_filename.remove_at(slot)
	refresh_info()


func _on_save_area_pressed():
	if get_slot_json(current_slot()) != null:
		if DirectLoadOnPress:
			emit_signal("game_loaded", get_slot_json(current_slot()))
		else:
			$H/V/Content/PromptLoad.show()
	elif not disable_saving:
		save_to(current_slot())


func save_to(slot: int):
	var sfname
	if slot < 0:
		print("Error: Save to negative slot: " + str(slot))
		return
	if slot == slot_filename.size():
		while true: 
			sfname = "save" + str(randi()) + ".json"
			if not FileAccess.file_exists("user://" + sfname):
				slot_filename.push_back(sfname)
				break
	else:
		sfname = slot_filename[slot]
		
	var savefile = FileAccess.open("user://" + sfname, FileAccess.WRITE)
	savefile.store_line(JSON.stringify(gather_save_data()))
	savefile.flush()
	savefile.close()
	
	refresh_info()


func gather_save_data() -> Dictionary:
	var save_nodes = get_tree().get_nodes_in_group("savable")
	var current_save = {}
	for node in save_nodes:
		var save_data = node.GetSaveData()
		current_save[save_data["type"]] = save_data
	
	current_save["date"] = Time.get_datetime_dict_from_system()
	return current_save


func _on_left_pressed():
	_move_page(-1)


func _on_right_pressed():
	_move_page(1)


func _move_page(step: int):
	$H/V/Content/VBox/HBox/HBox/Current.text = str(posmod(current_slot() + step, slot_filename.size()+1) + 1)
	refresh_info()


func _on_delete_pressed():
	$H/V/Content/PromptDelete.show()


func _on_prompt_delete_confirm(yes):
	$H/V/Content/PromptDelete.hide()
	if yes:
		delete(current_slot())
		refresh_info()


func _on_prompt_load_confirm(yes):
	$H/V/Content/PromptLoad.hide()
	if yes:
		emit_signal("game_loaded", get_slot_json(current_slot()))
