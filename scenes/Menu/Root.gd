extends MarginContainer

@onready var _sceneStack = [$Margin/VBox/Center/MainMenu]

func PlayButtonSfx():
	$"/root/Settings".PlaySfx("UI")


func _on_return_pressed():
	PlayButtonSfx()
	_sceneStack.pop_back().hide()
	$Return.visible = _sceneStack.size() > 1
	_sceneStack.back().show()


func changeScene(node):
	PlayButtonSfx()
	_sceneStack.back().hide()
	_sceneStack.push_back(node)
	node.show()
	$Return.visible = true


func _on_main_menu_b_continue():
	pass # Replace with function body.


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
	get_tree().change_scene_to_packed(load("res://scenes/Gameplay/Gameplay.tscn"))


func _on_choose_game_mode_custom_mode():
	pass # Replace with function body.


func _on_choose_game_mode_four_seasons():
	pass # Replace with function body.


func _on_choose_game_mode_time_rush():
	pass # Replace with function body.
