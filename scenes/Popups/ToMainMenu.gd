extends PanelContainer

signal confirm(yes: bool)


func _on_yes_pressed():
	emit_signal("confirm", true)


func _on_no_pressed():
	emit_signal("confirm", false)

