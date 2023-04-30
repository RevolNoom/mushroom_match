extends AspectRatioContainer


@export var spore_per_turn = 3
var spores: Array[Vector2i] = []
var spores_unfilled: Array[Vector2i] = []

var undo_queue = UndoQueue.new()

#TODO: Keep track of consistent state across move logic functions
var board_state = CreateCanvas(0)

func _ready():
	for c in $Grid.get_children():
		c.connect("chosen", _on_Cell_pressed)
	RandomizeInitialBoard()


func RandomizeInitialBoard():
	const INI_AMOUNT = 4
	var init_ids = $MushroomGenerator.GenerateNewIDs(INI_AMOUNT + spore_per_turn)
	var c = $Grid.get_children()
	c.shuffle()
	for i in range(0, init_ids.size()):
		var m = $MushroomGenerator.GetNewMushroom(init_ids[i])
		c[i].Add(m)
		if i < INI_AMOUNT:
			m.Grow()
			var cord = coord(c[i])
			board_state[cord.x][cord.y] = init_ids[i]
		else:
			m.Sprout()


func cell(coordinate: Vector2i) -> Cell:
	if coordinate.x < 0 or coordinate.x > 8 or\
		coordinate.y < 0 or coordinate.y > 8:
		return null
	return get_node(str(coordinate.y * $Grid.columns + coordinate.x))


# Return cell coordinate in [x, y]
func coord(board_cell: Cell) -> Vector2i:
	var id = int(board_cell.name.substr(0))
	return Vector2i(id % $Grid.columns, id / $Grid.columns)


var pressEnabled: bool = true
var lastPressed: Cell = null
func _on_Cell_pressed(c: Cell):
	if not pressEnabled:
		return
	if c.HasMushroom():
		if lastPressed != null:
			lastPressed.GetMushroom().SwingLazily()
		lastPressed = c
		#TODO: Move sfx to move function
		$"/root/Settings".PlaySfx("Mushroom")
		c.GetMushroom().BoingBoing()
	elif lastPressed:
		lastPressed.GetMushroom().SwingLazily()
		if coord(lastPressed) == coord(c):
			lastPressed = null
		else:
			var path = FindPath(coord(lastPressed), coord(c))
			if path.size() != 0:
				CalculateMoveLogic(path.front(), path.back())


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


# Breadth-first search to find path between two cells
# A cell can only go horizontally and vertically. Not diagonally
# Return arrays of cells that makes up the shortest path from @from to @to (inclusive both)
# Return empty array if there's no feasible path
func FindPath(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	const INFI = 99999
	var pathLengthChart = CreateCanvas(INFI)
	
	var queue = [from]
	
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
	
	# Destination unreachable
	if pathLengthChart[to.x][to.y] == INFI:
		return []
		
	# Traceback path from destination to start
	var path: Array[Vector2i] = [to]
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
	
	# Flip destination->start to start->destination
	path.reverse()
	return path


func CalculateMoveLogic(from: Vector2i, to: Vector2i):
	undo_queue.PushMove(from, to)
	
	board_state[to.x][to.y] = board_state[from.x][from.y]
	board_state[from.x][from.y] = 0

	if not PopLines(to):
		Grow()
		Sprout()
	Execute(undo_queue.GetActivities())
		

# Pop lines of mushrooms, with line searching starts from @at
# Modify @board_state as it pops
# Add POPs to undo_queue 
# Return true if POPs were made
func PopLines(at: Vector2i) -> bool:
	if board_state[at.x][at.y] == 0:
		return false
		
	var stack = [at]
	var poppables: Dictionary = {}
	
	while stack.size():
		var startPoint = stack.pop_back()
		for direction in [	Vector2i(0, 1),	# Horizontals
							Vector2i(1, 1),	# Diagonal /
							Vector2i(1, 0),	# Vertical
							Vector2i(1,-1)]:# Diagonal \
			var poppable_cells = count_dir(startPoint, direction)
			if poppable_cells.size() >= 5:
				stack.append_array(poppable_cells)
				for c in poppable_cells:
					poppables[c] = 1
	
	if poppables.keys().size():
		undo_queue.PushPop(cell(at).GetMushroom().ID, poppables.keys())
		for c in poppables.keys():
			board_state[c.x][c.y] = 0
		# After popping, some cells might become vacant for spore relocation
		Relocate()
		return true
	return false


func count_dir(start: Vector2i, dir: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = [start]
	var mushroom_id = cell(start).GetMushroom().ID
	for forward in [-1, 1]:
		for i in range(1, 9):
			var pos = start + i*dir*forward
			var c = cell(pos)
			if c != null and c.HasMushroom() and c.GetMushroom().ID == mushroom_id:
				result.append(pos)
			else:
				break
	return result



func Sprout():
	var cells = $Grid.get_children()
	cells.shuffle()
	
	spores.clear()
	for c in cells:
		if spores.size() >= spore_per_turn:
			break
		if c.IsEmpty():
			spores.push_back(coord(c))
	
	undo_queue.PushSprout($MushroomGenerator.GenerateNewIDs(spore_per_turn), spores.duplicate(true))

	
func IsFull():
	for cll in $Grid.get_children():
		if cll.IsEmpty():
			return false
	return true


func Grow():
	Relocate()
	
	var grow_cells: Array[Vector2i] = []
	for s in spores:
		var c = cell(s)
		if c.HasMushroom():
			#TODO: The board is full. Remove these spores 
			# TODO: free()?
			c.PopSpore().queue_free()
		else:
			grow_cells.push_back(s)
			board_state[s.x][s.y] = c.GetSpore().ID
	undo_queue.PushGrow(grow_cells)
	
	for s in spores:
		PopLines(s)
	spores.clear()
	
	if IsFull():
		emit_signal("full")


func Relocate():
	var mush_on_spore_cells = []
	for s in spores:
		if cell(s).HasMushroom():
			mush_on_spore_cells.append([s, cell(s)])

	if mush_on_spore_cells.size():
		var emptyCells = GetEmptyCells()
		emptyCells.shuffle()
		for mosc in mush_on_spore_cells:
			if emptyCells.size() == 0:
				break
			undo_queue.PushRelocate(mosc[0], emptyCells.back())
			spores.erase(mosc[0])
			spores.append(emptyCells.pop_back())


func GetEmptyCells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for i in range(0, $Grid.columns):	
		for j in range(0, $Grid.columns):
			if board_state[i][j] == 0 and cell(Vector2i(i, j)).IsEmpty():
				result.push_back(Vector2i(i, j))
	return result


# TODO:
func Execute(activities):
	var activity = activities.pop_back()
	match activity[0]:
		UndoQueue.MOVE:
			pass
		UndoQueue.RELOCATE:
			pass
		UndoQueue.GROW:
			pass
		UndoQueue.UN_GROW:
			pass
		UndoQueue.SPROUT:
			pass
		UndoQueue.UN_SPROUT:
			pass
		UndoQueue.POP:
			pass
		UndoQueue.UN_POP:
			pass
