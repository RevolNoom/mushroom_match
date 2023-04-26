extends Node

signal mushroom_moved_to(new_cell)


func EnableInput(enable: bool):
	_inputProcessEnabled = enable


var _board
func SetUp():
	_board = get_parent()
	for c in _board.get_node("Grid").get_children():
		c.connect("chosen", ProcessInput)#Callable(self, "ProcessInput"))


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
		c.GetMushroom().BoingBoingOnChosen()
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
