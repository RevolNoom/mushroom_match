extends PanelContainer


func _ready():
	$H/V/Content/Grid/MSlider.value = Settings.get_value("volume", "music")
	$H/V/Content/Grid/SSlider.value = Settings.get_value("volume", "sfx")
	
	$H/V/Content/Grid/Music.button_pressed = Settings.get_value("volume", "music_enabled")
	$H/V/Content/Grid/Sfx.button_pressed = Settings.get_value("volume", "sfx_enabled")


func _on_m_slider_value_changed(value):
	if value == $H/V/Content/Grid/MSlider.min_value:
		$"/root/Settings/Music".stop()
	elif not $"/root/Settings/Music".playing:
		$"/root/Settings/Music".play()
	
	Settings.set_value("volume", "music", value)
	$"/root/Settings/Music".volume_db = value


func _on_s_slider_drag_ended(value_changed):
	if value_changed:
		$"/root/Settings".SetSfxVolume($H/V/Content/Grid/SSlider.value)
		# Play test to help the player decide
		# whether that's enough
		$"/root/Settings".PlaySfx("UI")


func _on_sfx_toggled(button_pressed):
	Settings.sfx_enabled = button_pressed


func _on_music_toggled(button_pressed):
	var muted = button_pressed
	Settings.set_value("volume", "music_enabled", button_pressed)
	$"/root/Settings/Music".playing = muted


