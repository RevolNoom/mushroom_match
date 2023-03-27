extends MarginContainer

@export var spore_per_turn = 5

func _ready():
	GenerateNewSpores()
	$HBox/Board.AddSpores(ExtractNextTurnSpores())
	GenerateNewSpores()
	
func _on_board_next_turn():
	$HBox/Board.GrowSpores()
	if $HBox/Board.IsFull():
		print("Game Over")
		return
	$HBox/Board.AddSpores(ExtractNextTurnSpores())
	GenerateNewSpores()


func ExtractNextTurnSpores():
	var result = []
	for slot in $HBox/PanelRight/NextSpawn.get_children():
		if slot.get_child_count() != 0:
			result.append(slot.get_child(0))
			slot.remove_child(result.back())
			result.back().visible = true
	return result


func GenerateNewSpores():
	for i in range(0, spore_per_turn):
		var slot = $HBox/PanelRight/NextSpawn.get_child(i)
		var spore = preload("res://scenes/Gameplay/Mushroom.tscn").instantiate()
		spore._grown = false
		slot.add_child(spore)
		slot.texture = slot.get_child(0).texture
