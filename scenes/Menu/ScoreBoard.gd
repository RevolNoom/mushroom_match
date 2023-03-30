extends VBoxContainer

@onready var value = 0


func _on_board_add_score(amount):
	value += amount
	$Value.text = str(value)
