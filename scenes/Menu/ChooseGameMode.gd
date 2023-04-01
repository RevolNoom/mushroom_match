extends AspectRatioContainer

signal casual
signal time_rush
signal four_seasons
signal custom_mode

func _on_casual_pressed():
	emit_signal("casual")


func _on_time_rush_pressed():
	emit_signal("time_rush")


func _on_four_seasons_pressed():
	emit_signal("four_seasons")


func _on_custom_mode_pressed():
	emit_signal("custom_mode")
