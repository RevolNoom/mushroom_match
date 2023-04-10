extends PanelContainer


signal b_home
signal b_retry


func SetScore(score: String):
	$ARC/VBox/Content/VBox/Score.text = score
