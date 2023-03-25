extends AspectRatioContainer

func _ready():
	for c in $Grid.get_children():
		c.connect("chosen", Callable(self, "ProcessInput"))
	StartGameplay()


func cell(row, col) -> Cell:
	return $Grid.get_node(str(row * 9 + col))
	
	
func _on_grid_container_resized():
	custom_minimum_size = $Grid.size


func StartGameplay():
	RandomizeInitialBoard()


var _lastChosenCell: Cell
func ProcessInput(c: Cell):
	if not c.HasMushroom():
		if _lastChosenCell == null:
			return
		elif _lastChosenCell.HasMushroom():
			MoveMushroom(_lastChosenCell, c)
	else:
		_lastChosenCell = c


func MoveMushroom(from: Cell, to: Cell):
	to.AddMushroom(from.PopMushroom())
	pass


# TODO: Check for poppable lines
# TODO: Randomize Mushroom type
func RandomizeInitialBoard():
	var c = $Grid.get_children()
	c.shuffle()
	for i in range(0, 10):
		c[i].AddMushroom(preload("res://scenes/Gameplay/Mushroom.tscn").instantiate())
		

func SpraySpores():
	pass


func PopLines():
	pass


func CheckFullBoard():
	for cell in $Grid.get_children():
		if cell.IsEmpty():
			return false
	return true


func GrowSpores():
	pass


func RelocateSpores():
	pass
	

