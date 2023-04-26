extends AspectRatioContainer


signal b_play
signal b_continue
signal b_tutorial
signal b_settings
signal b_credits
signal b_highscore


func _on_settings_pressed():
	emit_signal("b_settings")


func _on_credits_pressed():
	emit_signal("b_credits")


func _on_play_pressed():
	emit_signal("b_play")


func _on_continue_pressed():
	emit_signal("b_continue")


func _on_tutorial_pressed():
	emit_signal("b_tutorial")


func _on_highscore_pressed():
	emit_signal("b_highscore")
