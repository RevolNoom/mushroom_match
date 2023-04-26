extends PanelContainer

class_name SavePopup


# This export is a shortcut for Main menu's Continue
@export var DirectLoadOnPress = false


var slot_filename: Array = []
var slot_parsedJSON: Array = []


func _ready():
	RefreshSaveSlots()
	if GetSlotFilename(GetCurrentSlot()) != null:
		LoadSaveData(GetSlotJSON(GetCurrentSlot())[str(get_path())])


# Return current index in savefile_path
# which is 1-unit less than shown on UI
func GetCurrentSlot():
	return int($ARC/VBox/Content/VBox/HBox/HBox/Current.text) - 1


func RefreshSaveSlots():
	slot_filename.clear()
	var dir = DirAccess.open("user://")
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		if file.begins_with("save"):
			slot_filename.append(file)
			slot_parsedJSON.append(null)
	
	$ARC/VBox/Content/VBox/HBox/HBox/Max.text = str(slot_filename.size() + 1)
	dir.list_dir_end()


func WriteSave(slot: int, filename: String):
	if slot >= slot_filename.size():
		slot_filename.append(filename)
		slot_parsedJSON.append(null)
	
	if slot_filename[slot] != filename:
		slot_parsedJSON[slot] = null
		

func GetSlotFilename(slot: int):
	if slot != clamp(slot, 0, slot_filename.size()-1):
		return null
	return slot_filename[slot]
	

func GetSlotJSON(slot: int):
	if slot != clamp(slot, 0, slot_parsedJSON.size()-1) or\
		GetSlotFilename(slot) == null:
		return null
	
	if slot_parsedJSON[slot] == null:
		slot_parsedJSON[slot] = GetParsedJSONSaveFile(slot_filename[slot])
		
	return slot_parsedJSON[slot]


func DeleteSlot(slot: int):
	DirAccess.remove_absolute("user://"+slot_filename[slot])
	slot_filename[slot] = null
	slot_parsedJSON[slot] = null


# Return a dictionary, that's parsed json in the form: 
# {
# "node_path1": {keys: attributes},
# "node_path2": {keys: attributes},
# }
func GetParsedJSONSaveFile(filename: String):
	if filename == null:
		return null
		
	var savefile = FileAccess.open("user://" + filename, FileAccess.READ)
	if savefile == null:
		print(FileAccess.get_open_error())
		return null
	
	var return_result = {}
	var json = JSON.new()
	while savefile.get_position() < savefile.get_length():
		var line = savefile.get_line()
		var result = json.parse(line)
		if not result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", line, " at line ", json.get_error_line())
			continue
			
		var parse_result = json.get_data()
		return_result[parse_result["path"]] = parse_result
	savefile.close()
	return return_result
	

func _on_save_area_pressed():
	if DirectLoadOnPress:
		ReloadProgress(GetSlotJSON(GetCurrentSlot()))
		return
	elif GetSlotJSON(GetCurrentSlot()) != null:
		$ARC/VBox/Content/PromptLoad.show()
		return
	
	SaveTo(GetCurrentSlot())


func SaveTo(slot: int):
	if GetSlotJSON(slot) != null:
		DeleteSlot(GetCurrentSlot())
	
	var savefile
	while true: 
		var sfname = "save" + str(randi()) + ".json"
		if not FileAccess.file_exists("user://" + sfname):
			savefile = FileAccess.open("user://" + sfname, FileAccess.WRITE)
			WriteSave(slot, sfname)
			break
			
	var savedata = GatherCurrentSaveData()
	for node in savedata.keys():
		savefile.store_line(JSON.stringify(savedata[node]))
	savefile.flush()
	savefile.close()
	
	LoadSaveData(GetSlotJSON(slot)[str(get_path())])
	
	$ARC/VBox/Content/VBox/HBox/HBox/Max.text= str(slot_filename.size()+1)


func GatherCurrentSaveData() -> Dictionary:
	var save_nodes = get_tree().get_nodes_in_group("savable")
	var current_save = {}
	current_save[str(get_path())] = {}
	for node in save_nodes:
		var save_data = node.GetSaveData()
		
		if save_data["type"] == "board":
			current_save[str(get_path())]["board"] = save_data
		for stamp in ["score", "time_elapsed"]:
			if save_data.has(stamp):
				current_save[str(get_path())][stamp] = save_data[stamp]
			
			
		if current_save.has(str(node.get_path())):
			current_save[str(node.get_path())].merge(save_data)
		else:
			current_save[str(node.get_path())] = save_data
	return current_save


func GetSaveData():
	return {
		"type": "save_popup",
		"path": get_path(),
		#"score": 0,
		"date": Time.get_datetime_dict_from_system(),
		#"time_elapsed": ""
		#"board": board save data (for screenshot
	}


func LoadSaveData(savedata):
	if savedata == null:
		$ARC/VBox/Content/VBox/ARC/MC.hide()
		$ARC/VBox/Content/Delete.hide()
		return
		
	var date = savedata["date"]
	$ARC/VBox/Content/VBox/ARC/MC/Board/VBox/Date.text =\
		"Date: " + ("0" if date["day"] < 10 else "") + str(date["day"]) + "-"\
				+ ("0" if date["month"] < 10 else "") + str(date["month"]) + "-"\
				+ str(date["year"]) + " "\
				+ ("0" if date["hour"] < 10 else "") + str(date["hour"]) + ":"\
				+ ("0" if date["minute"] < 10 else "") + str(date["minute"])
				
	$ARC/VBox/Content/VBox/ARC/MC/Board/VBox/Score.text = "Score: " + savedata["score"]
	$ARC/VBox/Content/VBox/ARC/MC/Board/VBox/Gametime.text = "Gametime: " + savedata["time_elapsed"]
	$ARC/VBox/Content/VBox/ARC/MC/Board.LoadSaveData(savedata["board"])
	
	$ARC/VBox/Content/VBox/ARC/MC.show()
	$ARC/VBox/Content/Delete.show()


func _on_left_pressed():
	MovePage(-1)


func _on_right_pressed():
	MovePage(1)


func MovePage(step: int):
	$ARC/VBox/Content/VBox/HBox/HBox/Current.text = str(posmod(GetCurrentSlot() + step, slot_filename.size()+1) + 1)
	if GetSlotJSON(GetCurrentSlot()) == null:
		LoadSaveData(null)
	else:
		var json = GetSlotJSON(GetCurrentSlot())
		LoadSaveData(json[str(get_path())])


func _on_delete_pressed():
	$ARC/VBox/Content/PromptDelete.show()


func _on_prompt_delete_confirm(yes):
	$ARC/VBox/Content/PromptDelete.hide()
	if yes:
		DeleteSlot(GetCurrentSlot())
		LoadSaveData(null)


func _on_prompt_load_confirm(yes):
	$ARC/VBox/Content/PromptLoad.hide()
	if yes:
		ReloadProgress(GetSlotJSON(GetCurrentSlot()))
		

func ReloadProgress(savefile):
	var save_nodes = savefile.keys()
	for node in save_nodes:
		get_node(node).LoadSaveData(savefile[node])
