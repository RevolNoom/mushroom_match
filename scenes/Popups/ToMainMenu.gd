extends PanelContainer

signal to_home(yes: bool)


func _on_yes_pressed():
	emit_signal("to_home", true)


func _on_no_pressed():
	emit_signal("to_home", false)

