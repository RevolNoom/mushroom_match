extends MarginContainer

signal to_main_menu


func _ready():
	#$VBox/Top/ARC.ratio = $VBox/Board.spore_per_turn
	update_next_turn_spores()
	check_unredo_state()
	#Pause()


func Play():
	$VBox/Top/Clock.Resume()


func Pause():
	$VBox/Top/Clock.Pause()


func _on_board_mushroom_popped(amount: int):
	var score = amount * (abs(amount) - 4)
	$VBox/Top/ScoreBoard/Value.text = str(int($VBox/Top/ScoreBoard/Value.text) + score)


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
	if yes:
		emit_signal("to_main_menu")
	else:
		HidePopup()


func _on_board_full():
	$Popups/GameOver.SetScore($VBox/Top/ScoreBoard/Value.text)
	ShowPopup($Popups/GameOver)


#TODO: Update highscores
func _on_game_over_b_home():
	_on_to_main_menu_confirm(true)
	
	
func _on_game_over_b_retry():
	pass # Replace with function body.


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
		"score": $VBox/Top/ScoreBoard/Value.text,
		"time_elapsed": $VBox/Top/Clock/Value.text,
		"date": Time.get_datetime_dict_from_system(),
	}


func LoadSaveData(save_data: Dictionary):
	$VBox/Top/ScoreBoard/Value.text = save_data["gameplay"]["score"]
	$VBox/Top/Clock.time_elapsed = $VBox/Top/Clock.ConvertFromString(save_data["gameplay"]["time_elapsed"])
	$VBox/Board.LoadSaveData(save_data["board"])
	
	update_next_turn_spores()
	check_unredo_state()


func _on_undo_pressed():
	$VBox/Board.undo()
	check_unredo_state()


func _on_redo_pressed():
	$VBox/Board.redo()
	check_unredo_state()


func _on_board_new_move():
	update_next_turn_spores()
	check_unredo_state()


func update_next_turn_spores():
	var spores = $VBox/Board.get_next_turn_spores()
	for i in range(0, $VBox/Top/NextSpawn.get_child_count()):
		var cell = $VBox/Top/NextSpawn.get_child(i)
		if i < spores.size():
			cell.visible = true
			cell.texture = spores[i]
		else:
			cell.visible = false
			
			
func check_unredo_state():
	$VBox/Bottom/Move/Undo.disabled = not $VBox/Board.is_undoable()
	$VBox/Bottom/Move/Redo.disabled = not $VBox/Board.is_redoable()


func _on_save_popup_game_loaded(save_data):
	LoadSaveData(save_data)
