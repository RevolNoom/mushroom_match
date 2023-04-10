extends MarginContainer


#TODO: Put Mushroom Generator inside Board

func _ready():
	$VBox/Top/ARC.ratio = $VBox/Board.spore_per_turn
	_on_board_next_turn()
	

func _on_board_next_turn():
	for i in range(0, $VBox/Top/ARC/NextSpawn.get_child_count()):
		var cell = $VBox/Top/ARC/NextSpawn.get_child(i)
		if i < $VBox/Board.spore_per_turn:
			cell.visible = true
			cell.texture = $VBox/Board.GetNextTurnSpores()[i].texture
		else:
			cell.visible = false


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


func _on_to_main_menu_to_home(yes):
	if yes:
		get_tree().change_scene_to_packed(load("res://scenes/Menu/Root.tscn"))
	else:
		HidePopup()


func _on_board_full():
	$Popups/GameOver.SetScore($VBox/Top/ScoreBoard/Value.text)
	ShowPopup($Popups/GameOver)


#TODO: Update highscores
func _on_game_over_b_home():
	_on_to_main_menu_to_home(true)
	
	
func _on_game_over_b_retry():
	pass # Replace with function body.


func _on_settings_pressed():
	ShowPopup($Popups/Settings)


func _on_x_pressed():
	HidePopup()


func _on_save_pressed():
	$Popups/SavePopup.SetSaveData($VBox/Board.GetScreenshot(),\
								$VBox/Top/ScoreBoard/Value.text,\
								$VBox/Top/Clock/Value.text)
	ShowPopup($Popups/SavePopup)
