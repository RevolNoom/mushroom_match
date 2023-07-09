extends TextureRect


signal to_main_menu


func _ready():
	Pause()
	_reset()
	update_next_turn_spores()


func _reset():
	HidePopup()
	$MC/VBox/Top/Board/Best/Value.text = str(Settings.get_value("player", "highscore"))
	$MC/VBox/Top/Board/Score/Value.text = "0"
	$MC/VBox/Top/Clock.reset()
	$MC/VBox/Board.reset()
	check_unredo_state()


func Play():
	$MC/VBox/Top/Clock.Resume()


func Pause():
	$MC/VBox/Top/Clock.Pause()


func _on_board_mushroom_popped(amount: int):
	var score = amount * (abs(amount) - 4)
	$MC/VBox/Top/Board/Score/Value.text = str(int($MC/VBox/Top/Board/Score/Value.text) + score)


func _on_home_pressed():
	ShowPopup($Popups/ToMainMenu)


func ShowPopup(popup_node):
	$Popups.show()
	popup_node.show()
	$Popups/X.show()


func HidePopup():
	$Popups.hide()
	for each in $Popups.get_children():
		each.hide()


func _on_to_main_menu_confirm(yes):
	HidePopup()
	if yes:
		emit_signal("to_main_menu")


func _on_board_full():
	$Popups/GameOver.SetScore($MC/VBox/Top/Board/Score/Value.text)
	ShowPopup($Popups/GameOver)


func _on_game_over_b_home():
	_on_to_main_menu_confirm(true)
	
	
func _on_game_over_b_retry():
	_reset()


func _on_settings_pressed():
	ShowPopup($Popups/Settings)


func _on_x_pressed():
	HidePopup()


func _on_save_load_pressed():
	$Popups/SavePopup.gather_save_data()
	ShowPopup($Popups/SavePopup)


func GetSaveData():
	return {
		"type": "gameplay",
		"score": $MC/VBox/Top/Board/Score/Value.text,
		"time_elapsed": $MC/VBox/Top/Clock/Value.text,
		"date": Time.get_datetime_dict_from_system(),
	}


func LoadSaveData(save_data: Dictionary):
	$MC/VBox/Top/Board/Score/Value.text = save_data["gameplay"]["score"]
	$MC/VBox/Top/Clock.time_elapsed = $MC/VBox/Top/Clock.ConvertFromString(save_data["gameplay"]["time_elapsed"])
	$MC/VBox/Board.LoadSaveData(save_data["board"])
	
	update_next_turn_spores()
	check_unredo_state()


func _on_undo_pressed():
	$MC/VBox/Board.undo()
	check_unredo_state()


func _on_redo_pressed():
	$MC/VBox/Board.redo()
	check_unredo_state()


func _on_board_new_move():
	update_next_turn_spores()
	check_unredo_state()


func update_next_turn_spores():
	var spores = $MC/VBox/Board.get_next_turn_spores()
	for i in range(0, $MC/VBox/ARC/NextSpawn.get_child_count()):
		var cell = $MC/VBox/ARC/NextSpawn.get_child(i)
		if i < spores.size():
			cell.visible = true
			cell.texture = spores[i]
		else:
			cell.visible = false
			
			
func check_unredo_state():
	$MC/VBox/Bottom/Move/Undo/Undo.visible = $MC/VBox/Board.is_undoable()
	$MC/VBox/Bottom/Move/Redo/Redo.visible = $MC/VBox/Board.is_redoable()


func _on_save_popup_game_loaded(save_data):
	HidePopup()
	LoadSaveData(save_data)


func _on_b_pressed():
	pass # Replace with function body.
