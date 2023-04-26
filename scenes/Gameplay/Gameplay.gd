extends MarginContainer

signal to_main_menu


func _ready():
	#$VBox/Top/ARC.ratio = $VBox/Board.spore_per_turn
	UpdateNextTurnSpores()
	#Pause()


func Play():
	$VBox/Top/Clock.Resume()
	$VBox/Board.EnableInput(true)


func Pause():
	$VBox/Top/Clock.Pause()
	$VBox/Board.EnableInput(false)
	

func _on_board_next_turn():
	UpdateNextTurnSpores()


func UpdateNextTurnSpores():
	for i in range(0, $VBox/Top/NextSpawn.get_child_count()):
		var cell = $VBox/Top/NextSpawn.get_child(i)
		if i < $VBox/Board.spore_per_turn:
			cell.visible = true
			cell.texture = $VBox/Board.GetNextTurnSpores()[i].texture
		else:
			cell.visible = false


func _on_board_add_score(amount):
	$VBox/Top/ScoreBoard/Value.text = str(int($VBox/Top/ScoreBoard/Value.text)+amount)


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
	$Popups/SavePopup.GatherCurrentSaveData()
	ShowPopup($Popups/SavePopup)



func GetSaveData():
	return {
		"type": "gameplay",
		"path": get_path(),
		"score": $VBox/Top/ScoreBoard/Value.text,
		"time_elapsed": $VBox/Top/Clock/Value.text
		# undo/redo array
		# index of un/redo array
	}


func LoadSaveData(save_data: Dictionary):
	$VBox/Top/ScoreBoard/Value.text = save_data["score"]
	$VBox/Top/Clock.time_elapsed = $VBox/Top/Clock.ConvertFromString(save_data["time_elapsed"])

