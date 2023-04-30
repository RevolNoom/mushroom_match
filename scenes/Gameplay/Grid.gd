extends GridContainer


@export var spore_per_turn = 5
var spores: Array[Vector2i] = []

func _ready():
	for c in get_children():
		c.connect("chosen", ProcessInput)
	RandomizeInitialBoard()
	Sprout()
	
	
func Sprout():
	var cells = get_children()
	cells.shuffle()
	
	spores.clear()
	
	for c in cells:
		if spores.size() >= spore_per_turn:
			break
		if c.IsEmpty():
			spores.push_back(coord(c))
	
	emit_signal("sprout", $MushroomGenerator.GenerateNewIDs(spore_per_turn), spores.duplicate(true))



# iv = initial value
func CreateCanvas(iv):
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
	return get_node(str(coordinate.y * columns + coordinate.x))


# Return cell coordinate in [x, y]
func coord(board_cell: Cell) -> Vector2i:
	var id = int(board_cell.name.substr(0))
	return Vector2i(id % columns, id / columns)
	



func _on_input_processor_mushroom_moved_to(new_cell):
	if PopLines(coord(new_cell)) == 0:
		Grow()
		Sprout()
		spores = $MushroomGenerator.GenerateMushrooms(spore_per_turn)
		emit_signal("next_turn")


func RandomizeInitialBoard():
	var init_ids = $MushroomGenerator.GenerateNewIDs(4)
	var c = $Grid.get_children()
	c.shuffle()
	for i in range(0, init_ids.size()):
		c[i].Add($MushroomGenerator.GetNewMushroom(init_ids[i]))


# Pop lines of mushrooms, with line searching starts from startingCells
# All mushrooms have been grown before searching is initiated
# Return amount of score increased
func PopLines(startingCell: Vector2i) -> int:
	#Note: Color_canvas is actually transposed Board
	# Actually, its transposition depends on how you lay it out
	# As long as you are consistent in indexing rule, you are fine
	var color_canvas=CreateCanvas(0)
	
	var c = startingCell
	
	var stack = [startingCell]
	
	while stack.size():
		var startPoint = stack.pop_back()
		for direction in [	Vector2i(0, 1),	# Horizontals
							Vector2i(1, 1),	# Diagonal /
							Vector2i(1, 0),	# Vertical
							Vector2i(1,-1)]:# Diagonal \
			if count_dir(cell(startPoint), direction) >= 5:
				color_canvas[c.x][c.y] = 1
				stack.append_array(paint_dir(cell(startPoint), direction, color_canvas))

	var id = 0
	var at: Array[Vector2i] = []
	for i in range(0, 9):
		for j in range(0, 9):
			if color_canvas[i][j] == 1:
				at.push_back(Vector2i(i, j))
				id = cell(at.back()).GetMushroom().ID

	# TODO: Send and receive signal Pop
	emit_signal("pop", id, at)


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
func paint_dir(startCell: Cell, dir: Vector2i, color_canvas: Array) -> Array:
	var new_cells_painted = []
	var crd = coord(startCell)
	for forward in [-1, 1]:
		for i in range(0, 9):
			var pos = crd + i*dir*forward
			var cll = cell(pos)
			if cll != null and cll.HasMushroom() and cll.GetMushroom().ID == startCell.GetMushroom().ID:
				if color_canvas[pos.x][pos.y] == 0:
					color_canvas[pos.x][pos.y] = 1
					new_cells_painted.append(pos)
			else:
				break
	return new_cells_painted


func IsFull():
	for cll in $Grid.get_children():
		if cll.IsEmpty():
			return false
	return true


func Grow():
	RelocateSporesIfNeeded()
	
	for sc in spored_cells:
		if sc.HasMushroom(): #TODO: The board is full. Remove these spores 
			pass #sc.Pop()
		else:
			sc.GrowSporeIntoMushroom()
	
	for sc in spored_cells:
		PopLines(coord(sc))
	spored_cells.clear()
	
	if IsFull():
		emit_signal("full")


#TODO: Relocate after popping lines
func RelocateSporesIfNeeded():
	var mush_on_spore_cells = []
	var spores_to_relocate = []
	for sc in spored_cells:
		if sc.HasMushroom():
			mush_on_spore_cells.append(sc)

	for mosc in mush_on_spore_cells:
		spored_cells.erase(mosc)
		spores_to_relocate.append(mosc.PopSpore())
	#TODO:
	#Sprout(spores_to_relocate)


# It must be guaranteed that there's a path between them
func Move(start: Vector2i, end: Vector2i):
	MoveMushroom(FindPath(_board.cell(start), _board.cell(end)))




var _inputProcessEnabled: bool = true
var _lastChosenCell: Cell = null
var _chosenCell: Cell = null
func ProcessInput(c: Cell):
	#print("processing")
	if not _inputProcessEnabled:
		return
	
	#print("enabled")
	if c.HasMushroom():
		if _lastChosenCell != null:
			_lastChosenCell.GetMushroom().SwingLazily()
		_lastChosenCell = c
		$"/root/Settings".PlaySfx("Mushroom")
		c.GetMushroom().BoingBoing()
		#print("processing1")
		
	elif _lastChosenCell != null and _lastChosenCell.HasMushroom():
		#print("processing2")
		_lastChosenCell.GetMushroom().SwingLazily()
		if _board.coord(_lastChosenCell) == _board.coord(c):
			_lastChosenCell = null
		else:
			_chosenCell = c
			var path = FindPath(_lastChosenCell, _chosenCell)
			if path.size() != 0:
				MoveMushroom(path)
			# Don't remove 'else'.
			# _lastChosenCell is used after MoveMushroom finish tweening 
			else:	
				_lastChosenCell = null
	
	#print("last chosen: " + ("null" if _lastChosenCell == null else _lastChosenCell.name))
	#print("chosen: " + ("null" if _chosenCell == null else _chosenCell.name))
	

# Breadth-first search to find path between two cells
# A cell can only go horizontally and vertically. Not diagonally
# Return arrays of cells that makes up the shortest path from @from to @to (inclusive both)
# Return empty array if there's no feasible path
func FindPath(from: Cell, to: Cell) -> Array:
	const INFI = 99999
	var pathLengthChart = _board.CreateCanvas(INFI)
	
	var queue = [_board.coord(from)]
	
	pathLengthChart[queue.back().x][queue.back().y] = 0
	
	while queue.size():
		var start = queue.pop_front()
		for direction in [Vector2i(0, 1),
							Vector2i(1, 0),
							Vector2i(0, -1),
							Vector2i(-1, 0)]:
			var hop = start+direction
			if _board.cell(hop) == null or _board.cell(hop).HasMushroom():
				continue
			if pathLengthChart[start.x][start.y] + 1 < pathLengthChart[hop.x][hop.y]:
				queue.push_back(hop)
				pathLengthChart[hop.x][hop.y] = pathLengthChart[start.x][start.y] + 1
	
	var c_to = _board.coord(to)
	
	# Destination unreachable
	if pathLengthChart[c_to.x][c_to.y] == INFI:
		return []
		
	var path = [c_to]
	while pathLengthChart[path.back().x][path.back().y] != 0:
		for direction in [Vector2i(0, 1),
							Vector2i(1, 0),
							Vector2i(0, -1),
							Vector2i(-1, 0)]:
			var cur_hop = path.back()+direction
			if _board.cell(cur_hop) != null and\
				pathLengthChart[cur_hop.x][cur_hop.y] < pathLengthChart[path.back().x][path.back().y]:
				path.append(cur_hop)
				break
	
	# Change the orientation from destination->start to start->destination
	path.reverse()
	return path


func MoveMushroom(path: Array):
	$"/root/Settings".PlaySfx("Mushroom")
	
	_inputProcessEnabled = false
	$Path2D.curve.clear_points()
	for coordinate in path:
		$Path2D.curve.add_point(_board.cell(coordinate).get_node("Center").global_position)#cell(coordinate).get_node("Center").global_position)
	
	$Path2D/PathFollow2D.progress_ratio = 0
	$Path2D/PathFollow2D/RemoteTransform2D.remote_path = _lastChosenCell.GetMushroom().get_path()
	_lastChosenCell.GetMushroom().z_index = $Path2D/PathFollow2D/RemoteTransform2D.z_index
	
	var tween = get_tree().create_tween()
	tween.tween_property($Path2D/PathFollow2D, "progress_ratio", 1, 0.3 + path.size()*0.06).set_trans(Tween.TRANS_SINE)
	
	tween.connect("finished", _on_tween_movement_complete)


func _on_tween_movement_complete():
	$Path2D/PathFollow2D/RemoteTransform2D.remote_path = ""
	_lastChosenCell.GetMushroom().z_index = 0
	_chosenCell.AddMushroom(_lastChosenCell.PopMushroom())
	var cell = _chosenCell
	_chosenCell = null
	_lastChosenCell = null
	emit_signal("mushroom_moved_to", cell)
	
	_inputProcessEnabled = true
