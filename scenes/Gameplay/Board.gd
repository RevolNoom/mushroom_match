extends AspectRatioContainer


const spore_per_turn = 3

# TODO: Refactor board_state into UndoQueue
var uq = UndoQueue.new()


func _ready():
	for c in $Grid.get_children():
		c.connect("chosen", _on_Cell_pressed)
	RandomizeInitialBoard()


func RandomizeInitialBoard():
	const INI_AMOUNT = 4
	var m_ids = $MushroomGenerator.GenerateNewIDs(INI_AMOUNT)
	var s_ids = $MushroomGenerator.GenerateNewIDs(spore_per_turn)
	var c = $Grid.get_children()
	c.shuffle()

	for i in range(0, m_ids.size()):
		var m = $MushroomGenerator.GetNewMushroom(m_ids[i])
		c[i].Add(m)
		m.Grow()
		
	for i in range(0, s_ids.size()):
		var m = $MushroomGenerator.GetNewMushroom(s_ids[i])
		c[c.size() - spore_per_turn + i].Add(m)
		m.Sprout()
	
	var m_at: Array[Vector2i] = []
	for mc in c.slice(0, INI_AMOUNT - 1):
		m_at.push_back(coord(mc))
		
	var s_at: Array[Vector2i] = []
	for sc in c.slice(c.size() - spore_per_turn, c.size() -1):
		s_at.push_back(coord(sc))
	uq.Init(CreateCanvas([0, 0]), m_ids, m_at, s_ids, s_at)


func cell(coordinate: Vector2i) -> Cell:
	if coordinate.x < 0 or coordinate.x > 8 or\
		coordinate.y < 0 or coordinate.y > 8:
		return null
	return $Grid.get_node(str(coordinate.y * $Grid.columns + coordinate.x))


# Return cell coordinate in [x, y]
func coord(board_cell: Cell) -> Vector2i:
	var id = int(board_cell.name.substr(0))
	return Vector2i(id % $Grid.columns, id / $Grid.columns)


var pressEnabled: bool = true
var lastPressed: Cell = null
func _on_Cell_pressed(c: Cell):
	if not pressEnabled:
		return
	#print("pressed")
	#print(str(coord(c)) + " has mushroom? " + str(c.HasMushroom()))
	if c.HasMushroom():
		if lastPressed != null:
			lastPressed.GetMushroom().SwingLazily()
		lastPressed = c
		c.GetMushroom().BoingBoing()
	elif lastPressed:
		lastPressed.GetMushroom().SwingLazily()
		if coord(lastPressed) != coord(c):
			var path = FindPath(coord(lastPressed), coord(c))
			if path.size() != 0:
				CalculateMoveLogic(path.front(), path.back())
		lastPressed = null

# iv = initial value
func CreateCanvas(iv) -> Array[Array]:
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
	uq.PushMove(from, to)
	
	if not PopLines(to):
		Grow()
		Sprout()
	Execute(uq.GetActivities())
		

# Pop lines of mushrooms, with line searching starts from @at
# Modify @board_state as it pops
# Add POPs to uq 
# Return true if POPs were made
func PopLines(at: Vector2i) -> bool:
	if uq.State().raw()[at.x][at.y][0] == 0:
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
		uq.PushPop(cell(at).GetMushroom().ID, poppables.keys())
		return true
	return false


func count_dir(start: Vector2i, dir: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = [start]
	var mushroom_id = uq.State().raw()[start.x][start.y][0]
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
	var ids = $MushroomGenerator.GenerateNewIDs(spore_per_turn)
	var sporecells: Array[Vector2i] = uq.State().GetEmptyCells()
	sporecells.shuffle()
	while sporecells.size() < spore_per_turn:
		var c = Vector2i(randi_range(0, $Grid.columns-1), randi_range(0, $Grid.columns-1))
		if uq.State().raw()[c.x][c.y][0] != 0 and not sporecells.has(c):
			sporecells.push_back(c)
	
	uq.PushSprout(ids, sporecells)

	
func IsFull():
	return uq.State().GetEmptyCells().size() == 0


func Grow():
	var emptyCells = uq.State().GetEmptyCells()
	emptyCells.shuffle()
	
	var spores = uq.State().GetSporeCells()
	var rel = []
	for s in spores:
		if uq.State().raw()[s.x][s.y][0] != 0:
			if emptyCells.size() == 0:
				break
			var new_cell = emptyCells.pop_back()
			uq.PushRelocate(s, new_cell)
			rel.push_back([s, emptyCells.back()])
	
	var grow_cells: Array[Vector2i] = []
	for s in uq.State().GetSporeCells():
		if uq.State().raw()[s.x][s.y][0] == 0:
			grow_cells.append(s)
	uq.PushGrow(grow_cells)
	
	for s in grow_cells:
		PopLines(s)
	
	if IsFull():
		emit_signal("full")



# TODO:
func Execute(activities):
	pressEnabled = false
	while activities.size():
		var activity = activities.pop_back()
		match activity[0]:
			UndoQueue.MOVE:
				await DoMove(Vector2i(activity[1], activity[2]), Vector2i(activity[3], activity[4]))
				print("Moved")
				print("cell global position: " + str(cell(Vector2i(activity[3], activity[4])).global_position))
				print("mushroom g_position: " + str(cell(Vector2i(activity[3], activity[4])).GetMushroom().global_position))
			UndoQueue.RELOCATE:
				await DoRelocate(Vector2i(activity[1], activity[2]), Vector2i(activity[3], activity[4]))
			UndoQueue.GROW:
				await DoGrow()
			UndoQueue.UN_GROW:
				await Ungrow()
			UndoQueue.SPROUT:
				await DoSprout()
			UndoQueue.UN_SPROUT:
				await Unsprout()
			UndoQueue.POP:
				await DoPop()
			UndoQueue.UN_POP:
				await Unpop()
	
	pressEnabled = true


func DoMove(from: Vector2i, to: Vector2i):
	$"/root/Settings".PlaySfx("Mushroom")

	var path = FindPath(from, to)
	$MovePath.curve.clear_points()
	for coordinate in path:
		$MovePath.curve.add_point(cell(coordinate).center_position())#.get_node("Center").global_position)
	
	$MovePath/PathFollow2D.progress_ratio = 0
	var mushroom = cell(from).GetMushroom()
	$MovePath/PathFollow2D/RemoteTransform2D.remote_path = mushroom.get_path()
	mushroom.z_index = $MovePath/PathFollow2D/RemoteTransform2D.z_index
	
	var tween = get_tree().create_tween()
	tween.tween_property($MovePath/PathFollow2D, "progress_ratio", 1, 0.3 + path.size()*0.06).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	mushroom.z_index = 0
	mushroom.GetCell().remove_child(mushroom)
	cell(to).Add(mushroom)


func DoRelocate(from: Vector2i, to: Vector2i):
	var c = cell(from)
	var s = c.GetSpore()
	c.remove_child(s)
	cell(to).Add(s)
	await s.Sprout()
	
	
func DoPop():
	pass
func DoSprout():
	pass
func DoGrow():
			#TODO: The board is full. Remove these spores 
			# TODO: PUT THIS IN DOGROW
			#c.PopSpore().queue_free()
	pass

func Ungrow():
	pass

func Unsprout():
	pass

func Unpop():
	pass

func GetSaveData():
	var canvas = CreateCanvas(0)
	for cll in $Grid.get_children():
		var c = coord(cll)
		if cll.HasMushroom():
			canvas[c.x][c.y] = cll.GetMushroom().ID
		elif cll.HasSpore():
			canvas[c.x][c.y] = - cll.GetSpore().ID
	
	var nts = []
	for i in uq.State().GetSporeCells():
		nts.push_back(cell(i).GetMushroom().ID)
		
	return {
		"type": "board",
		"path": get_path(),
		
		# Positive id is mushroom. Negative is Spore
		"canvas": canvas,
		"next_turn_spore": nts,
		"generator": $MushroomGenerator.GetSaveData()
		}


func LoadSaveData(save_data: Dictionary):
	$MushroomGenerator.LoadSaveData(save_data["generator"])
	
	# TODO: Freeing is not my concern for now
	#for sc in spored_cells:
	#	spored_cells.free()
	
	for i in range(0, 9):
		for j in range(0, 9):
			var c = cell(Vector2i(i, j))
			#c.Clear()
			
			var id = save_data["canvas"][i][j]
			if id < 0:
			#	c.AddSpore($MushroomGenerator.GetNewMushroom(-id))
				pass
			elif id > 0:
				pass
			#	c.AddMushroom($MushroomGenerator.GetNewMushroom(id))
