extends MarginContainer

@export var spore_per_turn = 5


func _ready():
	$MushroomGenerator.RandomizeGeneratingMushroomSet(7)
	$VBox/Board.RandomizeInitialBoard($MushroomGenerator.GenerateMushrooms(10))
	GenerateNewSpores()
	$VBox/Board.AddSpores(next_turn_spore)
	GenerateNewSpores()
	
	$VBox/Top/ARC.ratio = spore_per_turn
	for i in range(spore_per_turn, $VBox/Top/ARC/NextSpawn.get_child_count()):
		$VBox/Top/ARC/NextSpawn.get_node(str(i)).visible = false
	

func _on_board_next_turn():
	$VBox/Board.GrowSpores()
	if $VBox/Board.IsFull():
		print("Game Over")
		return
	$VBox/Board.AddSpores(next_turn_spore)
	GenerateNewSpores()


var next_turn_spore: Array
func ExtractNextTurnSpores():
	return next_turn_spore


func GenerateNewSpores():
	next_turn_spore = $MushroomGenerator.GenerateMushrooms(spore_per_turn)
	for i in range(0, spore_per_turn):
		var slot = $VBox/Top/ARC/NextSpawn.get_child(i)
		next_turn_spore[i]._grown = false
		slot.texture = next_turn_spore[i].texture
