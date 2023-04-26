extends Path2D

signal done


func Move(from: Cell, to: Cell, board):
	MoveMushrooms(FindPath(from, to, board), board)


func MoveMushrooms(path: Array, board):
	$"/root/Settings".PlaySfx("Mushroom")
	
	#_inputProcessEnabled = false
	curve.clear_points()
	for coordinate in path:
		curve.add_point(board.cell(coordinate).get_node("Center").global_position)#cell(coordinate).get_node("Center").global_position)
	
	path.back().AddMushroom(path.front().PopMushroom())
	$Path2D/PathFollow2D.progress_ratio = 0
	$Path2D/PathFollow2D/RemoteTransform2D.remote_path = path.back().GetMushroom().get_path()
	path.back().GetMushroom().z_index = $Path2D/PathFollow2D/RemoteTransform2D.z_index
	
	var tween = get_tree().create_tween()
	tween.tween_property($Path2D/PathFollow2D, "progress_ratio", 1, 0.3 + path.size()*0.06).set_trans(Tween.TRANS_SINE)
	
	tween.connect("finished", _on_tween_movement_complete)


# Breadth-first search to find path between two cells
# A cell can only go horizontally and vertically. Not diagonally
# Return arrays of cells that makes up the shortest path from @from to @to (inclusive both)
# Return empty array if there's no feasible path
func FindPath(from: Cell, to: Cell, board) -> Array:
	const INFI = 99999
	var pathLengthChart = board.CreateCanvas(INFI)
	
	var queue = [board.coord(from)]
	
	pathLengthChart[queue.back().x][queue.back().y] = 0
	
	while queue.size():
		var start = queue.pop_front()
		for direction in [Vector2i(0, 1),
							Vector2i(1, 0),
							Vector2i(0, -1),
							Vector2i(-1, 0)]:
			var hop = start+direction
			if board.cell(hop) == null or board.cell(hop).HasMushroom():
				continue
			if pathLengthChart[start.x][start.y] + 1 < pathLengthChart[hop.x][hop.y]:
				queue.push_back(hop)
				pathLengthChart[hop.x][hop.y] = pathLengthChart[start.x][start.y] + 1
	
	var c_to = board.coord(to)
	
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
			if board.cell(cur_hop) != null and\
				pathLengthChart[cur_hop.x][cur_hop.y] < pathLengthChart[path.back().x][path.back().y]:
				path.append(cur_hop)
				break
	
	# Change the orientation from destination->start to start->destination
	path.reverse()
	return path


func _on_tween_movement_complete():
	get_node($Path2D/PathFollow2D/RemoteTransform2D.remote_path).z_index = 0
	$Path2D/PathFollow2D/RemoteTransform2D.remote_path = ""
	emit_signal("done")
