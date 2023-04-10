extends PanelContainer


func _on_m_slider_value_changed(value):
	if value == $ARC/VBox/Content/Grid/MSlider.min_value:
		$"/root/Settings/Music".stop()
	elif not $"/root/Settings/Music".playing:
		$"/root/Settings/Music".play()
		
	$"/root/Settings/Music".volume_db = value


func _on_s_slider_drag_ended(value_changed):
	if value_changed:
		$"/root/Settings".SetSfxVolume($ARC/VBox/Content/Grid/SSlider.value)
		# Play test to help the player decide
		# whether that's enough
		$"/root/Settings".PlaySfx("UI")


func _on_sfx_toggled(button_pressed):
	$"/root/Settings".EnableSfx(button_pressed)


func _on_music_toggled(button_pressed):
	var muted = button_pressed
	$"/root/Settings/Music".playing = muted


