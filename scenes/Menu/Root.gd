extends Control


func _ready():
	pass
	
	
func _on_main_menu_new_game(mode, savedata):
	if savedata != null:
		$Gameplay.LoadSaveData(savedata)
	else:
		$Gameplay.Play()
	
	$MainMenu.hide()
	$Gameplay.show()


func _on_gameplay_to_main_menu():
	$Gameplay.hide()
	$Gameplay.Pause()
	$MainMenu.refresh()
	$MainMenu.show()
