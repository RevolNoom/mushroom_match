extends AspectRatioContainer

signal next_turn

func _ready():
	for c in $Grid.get_children():
		c.connect("chosen", Callable(self, "ProcessInput"))
	RandomizeInitialBoard()


func cell(coord: Vector2i) -> Cell:
	if coord.x < 0 or coord.x > 8 or\
		coord.y < 0 or coord.y > 8:
		return null
	return $Grid.get_node(str(coord.y*$Grid.columns + coord.x))


# Return cell coordinate in [x, y]
func coord(cell: Cell) -> Vector2i:
	var id = int(cell.name.substr(0))
	return Vector2i(id % $Grid.columns, id / $Grid.columns)
	
	
func _on_grid_container_resized():
	custom_minimum_size = $Grid.size


var _lastChosenCell: Cell
func ProcessInput(c: Cell):
	if not c.HasMushroom():
		if _lastChosenCell == null:
			return
		elif _lastChosenCell.HasMushroom():
			MoveMushroom(_lastChosenCell, c)
			PopLines([c])
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


func PopLines(startingCells: Array):	
	var color_canvas=[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],
						[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],
						[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]
	
	var color = 1
	
	for cell in startingCells:
		var c = coord(cell)
		if color_canvas[c.y][c.x] != 0:
			continue
		
		var stack = [c]
		
		while stack.size():
			var startPoint = stack.pop_back()
			for direction in [	Vector2i(0, 1),	# Horizontals
								Vector2i(1, 1),	# Diagonal /
								Vector2i(1, 0),	# Vertical
								Vector2i(1,-1)]:# Diagonal \
				if count_dir(cell(startPoint), direction) >= 5:
					stack.append_array(paint_dir(cell(startPoint), direction, color_canvas, color))
					
		color += 1
	
	#print(color_canvas)
	pop_lines(color_canvas, color)


func pop_lines(color_canvas: Array, max_color: int):
	var score = 0
	for color in range(1, max_color):
		var count = 0
		for i in range(0, 9):
			for j in range(0, 9):
				if color_canvas[i][j] == color:
					++count
					cell(Vector2i(j, i)).Pop().queue_free()
		score += count * (count-4)
	#print("Score: " + str(score))


func count_dir(startCell: Cell, dir: Vector2i) -> int:
	var result = 0
	for forward in [-1, 1]:
		for i in range(1, 9):
			var pos = coord(startCell) + i*dir*forward
			var cll = cell(pos)
			if cll != null and cll.HasMushroom() and cll._mushroom.ID == startCell._mushroom.ID:
				result += 1
			else:
				break
	return result + 1 #+1 for startCell


# Paint color_canvas in specified direction and starting point
# Return array of coords of new cells painted
func paint_dir(startCell: Cell, dir: Vector2i, color_canvas: Array, color: int) -> Array:
	var new_cells_painted = []
	var crd = coord(startCell)
	for forward in [-1, 1]:
		for i in range(0, 9):
			var pos = crd + i*dir*forward
			var cll = cell(pos)
			if cll != null and cll.HasMushroom() and cll._mushroom.ID == startCell._mushroom.ID:
				if color_canvas[pos.y][pos.x] == 0:
					color_canvas[pos.y][pos.x] = color
					new_cells_painted.append(pos)
			else:
				break
	return new_cells_painted


func IsFull():
	for cell in $Grid.get_children():
		if cell.IsEmpty():
			return false
	return true


func GrowSpores():
	RelocateSporesIfNeeded()
	
	for sc in spored_cells:
		if sc.HasMushroom(): #TODO: In case the board is too full
			pass #sc.Pop()
		else:
			sc.GrowSporeIntoMushroom()
	
	PopLines(spored_cells)
	spored_cells.clear()


#TODO: Relocate after popping lines
func RelocateSporesIfNeeded():
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
	

