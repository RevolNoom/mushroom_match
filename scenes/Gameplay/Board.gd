extends AspectRatioContainer

signal next_turn

func _ready():
	for c in $Grid.get_children():
		c.connect("chosen", Callable(self, "ProcessInput"))
	RandomizeInitialBoard()


func cell(row, col) -> Cell:
	return $Grid.get_node(str(row * 9 + col))
	
	
func _on_grid_container_resized():
	custom_minimum_size = $Grid.size


var _lastChosenCell: Cell
func ProcessInput(c: Cell):
	if not c.HasMushroom():
		if _lastChosenCell == null:
			return
		elif _lastChosenCell.HasMushroom():
			MoveMushroom(_lastChosenCell, c)
			emit_signal("next_turn")
	else:
		_lastChosenCell = c


func MoveMushroom(from: Cell, to: Cell):
	to.Add(from.Pop())


# TODO: Check for poppable lines
# TODO: Randomize Mushroom type
func RandomizeInitialBoard():
	var c = $Grid.get_children()
	c.shuffle()
	for i in range(0, 70):
		c[i].Add(preload("res://scenes/Gameplay/Mushroom.tscn").instantiate())


var spored_cells = []
func AddSpores(spore_list: Array):
	var cells = $Grid.get_children()
	cells.shuffle()
	for c in cells:
		if c.IsEmpty():
			c.Add(spore_list.pop_back())
			spored_cells.append(c)
			if spore_list.size() == 0:
				return


func PopLines():
	pass


func IsFull():
	for cell in $Grid.get_children():
		if cell.IsEmpty():
			return false
	return true


func GrowSpores():
	print("Before relocate:")
	for i in spored_cells:
		print (i.name)
		
	RelocateSpores()
	
	
	print("After relocate:")
	for i in spored_cells:
		print (i.name)
	
	print()
		
	for sc in spored_cells:
		sc.GrowSporeIntoMushroom()
	spored_cells.clear()


#TODO: Relocate after popping lines
func RelocateSpores():
	var mush_on_spore_cells = []
	var spores_to_relocate = []
	for sc in spored_cells:
		if sc.HasMushroom():
			mush_on_spore_cells.append(sc)
	
	if mush_on_spore_cells.size() != 0:
		for mosc in mush_on_spore_cells:
			spored_cells.erase(mosc)
			spores_to_relocate.append(mosc.Pop())
		AddSpores(spores_to_relocate)
	

