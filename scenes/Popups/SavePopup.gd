extends PanelContainer


class SaveData:
	var screenshot: ImageTexture
	var score: String
	var time_played: String # "?w ?d hh:mm:ss"
	var date: Dictionary # Datetime dict

var _current_save:= SaveData.new()

func SetSaveData(screenshot: ImageTexture, score: String, time_played: String):
	_current_save.screenshot = screenshot
	_current_save.score = score
	_current_save.time_played = time_played


func _exit_tree():
	_current_save.free()


# TODO: Button stylebox shows when clicked. Hide it
func _on_save_area_pressed():
	#if slot occupied:
	#	Show Warning Popup
	#else:
	$ARC/VBox/Content/VBox/ARC/Image.texture = _current_save.screenshot
	$ARC/VBox/Content/VBox/ARC/VBox/Score.text = _current_save.score
	$ARC/VBox/Content/VBox/ARC/VBox/Duration.text = _current_save.time_played
	_current_save.date = Time.get_datetime_dict_from_system()
	
	var csd = _current_save.date
	$ARC/VBox/Content/VBox/ARC/VBox/Date.text = str(csd["year"]) + "/"\
												+ str(csd["month"]) + "/"\
												+ str(csd["day"]) + " "\
												+ str(csd["hour"]) + ":"\
												+ str(csd["minute"]) + ":"\
												+ str(csd["second"])
	
	$ARC/VBox/Content/VBox/ARC/Image.show()
	$ARC/VBox/Content/VBox/ARC/VBox.show()
	$ARC/VBox/Content/VBox/ARC/SaveArea.text = "" # TODO: Rewrite "Empty Slot"
	# TODO: Save to user's storage
	# TODO: Create new Empty Page


func _on_left_pressed():
	pass # Replace with function body.


func _on_right_pressed():
	pass # Replace with function body.
