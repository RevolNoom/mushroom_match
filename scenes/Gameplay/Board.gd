extends AspectRatioContainer

signal next_turn
signal add_score(amount)


func _ready():
	for c in $Grid.get_children():
		c.connect("chosen", Callable(self, "ProcessInput"))


func CreateCanvas(initial_value):
	var iv = initial_value
	return [[iv, iv, iv, iv, iv, iv, iv, iv, iv],
			[iv, iv, iv, iv, iv, iv, iv, iv, iv],
			[iv, iv, iv, iv, iv, iv, iv, iv, iv],
			[iv, iv, iv, iv, iv, iv, iv, iv, iv],
			[iv, iv, iv, iv, iv, iv, iv, iv, iv],
			[iv, iv, iv, iv, iv, iv, iv, iv, iv],
			[iv, iv, iv, iv, iv, iv, iv, iv, iv],
			[iv, iv, iv, iv, iv, iv, iv, iv, iv],
			[iv, iv, iv, iv, iv, iv, iv, iv, iv]]
			

func cell(coordinate: Vector2i) -> Cell:
	if coordinate.x < 0 or coordinate.x > 8 or\
		coordinate.y < 0 or coordinate.y > 8:
		return null
	return $Grid.get_node(str(coordinate.y*$Grid.columns + coordinate.x))


# Return cell coordinate in [x, y]
func coord(board_cell: Cell) -> Vector2i:
	var id = int(board_cell.name.substr(0))
	return Vector2i(id % $Grid.columns, id / $Grid.columns)
	
	
func _on_grid_container_resized():
	custom_minimum_size = $Grid.size


var _lastChosenCell: Cell
func ProcessInput(c: Cell):
	if not c.HasMushroom():
		if _lastChosenCell == null:
			return
		elif _lastChosenCell.HasMushroom():
			if _lastChosenCell == c:
				_lastChosenCell = null
				#TODO: Turn off animation of last chosen mushroom
			else:
				var path = FindPath(_lastChosenCell, c)
				if path.size() != 0:
					MoveMushroom(_lastChosenCell, c)
					if PopLines([c]) == 0:
						emit_signal("next_turn")
	else:
		_lastChosenCell = c


# Breadth-first search to find path between two cells
# A cell can only go horizontally and vertically. Not diagonally
#TODO: Return arrays of cells that makes up the shortest path from @from to @to (inclusive both)
# Return empty array if there's no feasible path
func FindPath(from: Cell, to: Cell) -> Array:
	const INFI = 99999
	var pathLengthChart = CreateCanvas(INFI)
	
	var queue = [coord(from)]
	
	pathLengthChart[queue.back().x][queue.back().y] = 0
	
	while queue.size():
		var start = queue.pop_front()
		for direction in [Vector2i(0, 1),
							Vector2i(1, 0),
							Vector2i(0, -1),
							Vector2i(-1, 0)]:
			var hop = start+direction
			if cell(hop) == null or cell(hop).HasMushroom():
				continue
			if pathLengthChart[start.x][start.y] + 1 < pathLengthChart[hop.x][hop.y]:
				queue.push_back(hop)
				pathLengthChart[hop.x][hop.y] = pathLengthChart[start.x][start.y] + 1
	
	var c_to = coord(to)
	
	#for i in range(0, 9):
	#	var row = str(pathLengthChart[i][0])
	#	for j in range(1, 9):
	#		row += " " + str(pathLengthChart[i][j])
	#	print(row)
	
	# Destination unreachable
	if pathLengthChart[c_to.x][c_to.y] == INFI:
		#print("No path")
		return []
		
	var path = [c_to]
	while pathLengthChart[path.back().x][path.back().y] != 0:
		for direction in [Vector2i(0, 1),
							Vector2i(1, 0),
							Vector2i(0, -1),
							Vector2i(-1, 0)]:
			var cur_hop = path.back()+direction
			if cell(cur_hop) != null and\
				pathLengthChart[cur_hop.x][cur_hop.y] < pathLengthChart[path.back().x][path.back().y]:
				path.append(cur_hop)
				break
				
	#print("Path: " + str(path))
	return path


#TODO: Move on path returned by IsMovable()
func MoveMushroom(from: Cell, to: Cell):
	to.AddMushroom(from.PopMushroom())


# TODO: Check for poppable lines
# TODO: Randomize Mushroom type
func RandomizeInitialBoard(init_mushrooms: Array[Mushroom]):
	var c = $Grid.get_children()
	c.shuffle()
	for i in range(0, init_mushrooms.size()):
		c[i].AddMushroom(init_mushrooms[i])


var spored_cells = []
func AddSpores(spore_list: Array):
	var cells = $Grid.get_children()
	cells.shuffle()
	for c in cells:
		if c.IsEmpty():
			c.AddSpore(spore_list.pop_back())
			spored_cells.append(c)
			if spore_list.size() == 0:
				return


# Pop lines of mushrooms, with line searching starts from startingCells
# All mushrooms have been grown before searching is initiated
# Return amount of score increased
func PopLines(startingCells: Array) -> int:
	
	#Note: Color_canvas is actually transposed Board
	# Actually, its transposition depends on how you lay it out
	# As long as you are consistent in indexing rule, you are fine
	var color_canvas=CreateCanvas(0)
	
	var color = 1
	for cll in startingCells:
		var c = coord(cll)
		if color_canvas[c.x][c.y] != 0:
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

	return pop_lines(color_canvas, color)


func pop_lines(color_canvas: Array, max_color: int) -> int:
	var score = 0
	for color in range(1, max_color):
		var count = 0
		for i in range(0, 9):
			for j in range(0, 9):
				if color_canvas[i][j] == color:
					count+=1
					cell(Vector2i(i, j)).PopMushroom().queue_free()
		score += count * (count-4)
	emit_signal("add_score", score)
	return score
	


func count_dir(startCell: Cell, dir: Vector2i) -> int:
	var result = 0
	for forward in [-1, 1]:
		for i in range(1, 9):
			var pos = coord(startCell) + i*dir*forward
			var cll = cell(pos)
			if cll != null and cll.HasMushroom() and cll.GetMushroom().ID == startCell.GetMushroom().ID:
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
			if cll != null and cll.HasMushroom() and cll.GetMushroom().ID == startCell.GetMushroom().ID:
				if color_canvas[pos.x][pos.y] == 0:
					color_canvas[pos.x][pos.y] = color
					new_cells_painted.append(pos)
			else:
				break
	return new_cells_painted


func IsFull():
	for cll in $Grid.get_children():
		if cll.IsEmpty():
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
			spores_to_relocate.append(mosc.PopSpore())
		AddSpores(spores_to_relocate)
	

