extends MarginContainer

@onready var _sceneStack = [$Margin/VBox/Center/Menu]

# mode: Casual/Four seasons/...
# savedata: data for gameplay to load. Could be null
signal new_game(mode, savedata)

func PlayButtonSfx():
	$"/root/Settings".PlaySfx("UI")


func _on_return_pressed():
	PlayButtonSfx()
	_sceneStack.pop_back().hide()
	$Margin/VBox/Center/Return.visible = _sceneStack.size() > 1
	_sceneStack.back().show()


func changeScene(node):
	PlayButtonSfx()
	_sceneStack.back().hide()
	_sceneStack.push_back(node)
	node.show()
	$Margin/VBox/Center/Return.visible = true


func _on_main_menu_b_continue():
	changeScene($Margin/VBox/Center/SavePopup)


func _on_main_menu_b_credits():
	changeScene($Margin/VBox/Center/Credits)


func _on_main_menu_b_highscore():
	#changeScene()
	pass

func _on_main_menu_b_play():
	changeScene($Margin/VBox/Center/ChooseGameMode)


func _on_main_menu_b_settings():
	changeScene($Margin/VBox/Center/Settings)


func _on_main_menu_b_tutorial():
	pass # Replace with function body.


func _on_choose_game_mode_casual():
	emit_signal("new_game", "casual", null)


func _on_choose_game_mode_custom_mode():
	pass # Replace with function body.


func _on_choose_game_mode_four_seasons():
	pass # Replace with function body.


func _on_choose_game_mode_time_rush():
	pass # Replace with function body.


func _on_save_popup_game_loaded(save_data):
	emit_signal("new_game", "casual", save_data)
