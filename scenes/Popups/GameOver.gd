extends PanelContainer


signal b_home
signal b_retry


func SetScore(score: String):
	$H/V/Content/VBox/Score.text = score
	var best = Settings.get_value("player", "highscore")
	$H/V/Content/VBox/NewBest.visible = int(score) > best
	Settings.set_value("player", "highscore", max(int(score), best))


func _on_home_pressed():
	emit_signal("b_home")


func _on_retry_pressed():
	emit_signal("b_retry")
