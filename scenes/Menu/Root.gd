extends MarginContainer

@onready var _sceneStack = [$Margin/VBox/Center/MainMenu]


func _on_return_pressed():
	_sceneStack.pop_back().hide()
	$CornerShortcuts/Return.disabled = _sceneStack.size() == 1
	_sceneStack.back().show()


func changeScene(node):
	_sceneStack.back().hide()
	_sceneStack.push_back(node)
	node.show()
	$CornerShortcuts/Return.disabled = false
	
	
func _on_settings_pressed():
	changeScene($Margin/VBox/Center/Settings)


func _on_credits_pressed():
	changeScene($Margin/VBox/Center/Creditss)


func _on_play_pressed():
	changeScene($Margin/VBox/Center/ChooseGameMode)


func _on_continue_pressed():
	pass # Replace with function body.


func _on_how_to_play_pressed():
	pass # Replace with function body.


func _on_leaderboard_pressed():
	pass # Replace with function body.
