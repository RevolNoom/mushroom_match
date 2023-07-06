extends AspectRatioContainer

signal mushroom_popped(amount: int)
signal new_move()
signal full()


@export var spore_per_turn = 3
@export var initial_mushrooms = 25
var uq = UndoQueue.new()

var _astar = AStar2D.new()


func _ready():
	for c in $Grid.get_children():
		c.connect("chosen", _on_Cell_pressed)
		
	_init_astar()

	var c = $Grid.get_children()
	c.shuffle()
	
	var temp_cell = c.slice(0, initial_mushrooms)
	var temp_cids = []
	var mids = $MushroomGenerator.GenerateNewIDs(initial_mushrooms)
	for i in range(0, initial_mushrooms):
		var m = $MushroomGenerator.GetNewMushroom(mids[i])
		temp_cell[i].Add(m)
		m.Grow()
		_astar.set_point_disabled(id(temp_cell[i]))
		
	temp_cell = c.slice(c.size()-spore_per_turn)
	temp_cids = []
	for tc in temp_cell:
		temp_cids.push_back(id(tc))
	DoSprout($MushroomGenerator.GenerateNewIDs(spore_per_turn), temp_cids)
	emit_signal("new_move")


func get_next_turn_spores() -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	for cid in _get_spore_cells():
		textures.push_back(cell(cid).GetSpore().texture)
	return textures


func is_undoable() -> bool:
	return uq.HasPrev()


func is_redoable() -> bool:
	return uq.HasNext()


func undo():
	Execute(uq.GetActivitiesUndo())
	uq.Prev()
	

func redo():
	uq.Next()
	Execute(uq.GetActivities())


func _init_astar():
	for c in $Grid.get_children():
		_astar.add_point(id(c), c.center_position())
		
	for c in $Grid.get_children():
		var cid = id(c)
		for adj_coord in [
				cid - 10,
				cid + 10,
				cid - 1,
				cid + 1
				]:
			var adj_cell = cell(adj_coord)
			if adj_cell != null and not _astar.are_points_connected(cid, adj_coord):
				_astar.connect_points(cid, adj_coord)


func get_empty_cells() -> PackedInt32Array:
	var result: PackedInt32Array = []
	for c in $Grid.get_children():
		if c.IsEmpty():
			result.push_back(id(c))
	return result
	

func cell(cid: int) -> Cell:
	if 10 < cid and cid < 100 and cid%10 != 0:
		return $Grid.get_node(str(cid))
	return null


# Return cell coordinate in [x, y]
func id(c: Cell) -> int:
	return int(str(c.name))


func _is_on_edge(cid: int):
	return cid%10 in [1, 9]\
		or floor(cid/10.0) in [1, 9]


var lastPressed: Cell = null
func _on_Cell_pressed(c: Cell):
	if c.HasMushroom():
		if lastPressed != null:
			lastPressed.GetMushroom().SwingLazily()
		lastPressed = c
		c.GetMushroom().BoingBoing()
	elif lastPressed:
		lastPressed.GetMushroom().SwingLazily()
		if id(lastPressed) != id(c): 
			var path = _astar.get_id_path(id(lastPressed), id(c))
			if path.size() != 0:
				Move(path[0], path[path.size()-1])
		lastPressed = null


func Move(from: int, to: int):
	uq.PushMove(from, to)
	DoMove(from, to)
	
	if not PopLines(to):
		Grow()
		Sprout()
	
	emit_signal("new_move")


# Pop lines of mushrooms, with line searching starts from @at
# Add POPs to uq 
# Return true if POPs were made
func PopLines(cid: int) -> bool:
	if cell(cid).IsEmpty():
		return false
		
	var stack: Array[int] = [cid]
	var poppables: Dictionary = {}
	
	while stack.size():
		var startPoint = stack.pop_back()
		for direction in [	1,	# Horizontals
							11,	# Diagonal \
							10,	# Vertical
							9]:# Diagonal /
			var poppable_cells = count_dir(startPoint, direction)
			if poppable_cells.size() >= 5:
				for c in poppable_cells:
					if not poppables.has(c):
						# Mark this cell as popped
						poppables[c] = 1
						stack.append(c)
	
	if poppables.keys().size():
		uq.PushPop(cell(cid).GetMushroom().ID, poppables.keys())
		DoPop(poppables.keys())
		return true
	return false


func count_dir(start: int, dir: int) -> PackedInt32Array:
	var result: PackedInt32Array = [start]
	for forward in [-1, 1]:
		for i in range(1, 9):
			var pos = start + i*dir*forward
			if not _are_adjacent(pos, start + (i-1)*dir*forward):
				break
				
			var c = cell(pos)
			if c == null or not c.HasMushroom()\
					or c.GetMushroom().ID != cell(start).GetMushroom().ID:
				break
			result.append(pos)
	return result


# Return true if their difference in x,y coordinates is not larger than 2
func _are_adjacent(cid1: int, cid2: int):
	return abs(cid1 % 10 - cid2 % 10) + abs(floor(cid1 / 10.0) - floor(cid2 / 10.0)) <= 2


func Sprout():
	var ids = $MushroomGenerator.GenerateNewIDs(spore_per_turn)
	var cells_to_spore: Array = get_empty_cells()
	cells_to_spore.shuffle()
	if cells_to_spore.size() < spore_per_turn:
		var mushroom_taken_cells = $Grid.get_children()
		while cells_to_spore.size() < spore_per_turn:
			var c = mushroom_taken_cells.pick_random()
			if not c.IsEmpty():
				cells_to_spore.push_back(id(c))
			mushroom_taken_cells.erase(c)
	else:
		cells_to_spore = cells_to_spore.slice(0, spore_per_turn)
	
	uq.PushSprout(ids, cells_to_spore)
	DoSprout(ids, cells_to_spore)


func IsFull() -> bool:
	for c in $Grid.get_children():
		if c.IsEmpty():
			return false
	return true


func Grow():
	var need_relocation := PackedInt32Array()
	var grow_cells := PackedInt32Array()
	
	for cid in _get_spore_cells():
		if cell(cid).HasMushroom():
			need_relocation.push_back(cid)
		else:
			grow_cells.push_back(cid)
	
	if need_relocation.size():
		var ec: Array = get_empty_cells()
		var rel_to = PackedInt32Array()
		while ec.size() > 0 and need_relocation.size() > rel_to.size():
			var random_cell = ec.pick_random()
			rel_to.push_back(random_cell)
			ec.erase(random_cell)
		
		# Trim leftover cells because there are not enough empty cells
		while need_relocation.size() > rel_to.size():
			var back = need_relocation.size()-1
			cell(need_relocation[back]).PopSpore().queue_free()
			need_relocation.remove_at(back)
			
		DoRelocate(need_relocation, rel_to)
		uq.PushRelocate(need_relocation, rel_to)
		grow_cells.append_array(rel_to)
	
	DoGrow(grow_cells)
	uq.PushGrow(grow_cells)
	
	for s in grow_cells:
		PopLines(s)
	
	if IsFull():
		emit_signal("full")


func _get_spore_cells() -> PackedInt32Array:
	var result := PackedInt32Array()
	for c in $Grid.get_children():
		if c.HasSpore():
			result.push_back(id(c))
	return result


# TODO:
func Execute(activities):
	print("Executing: " + str(activities))
	while activities.size():
		var activity = activities.pop_front()
		match activity[0]:
			UndoQueue.MOVE:
				DoMove(activity[1], activity[2])
			UndoQueue.RELOCATE:
				DoRelocate(activity[1], activity[2])
			UndoQueue.GROW:
				DoGrow(activity[1])
			UndoQueue.UN_GROW:
				Ungrow(activity[1])
			UndoQueue.SPROUT:
				DoSprout(activity[1], activity[2])
			UndoQueue.UN_SPROUT:
				Unsprout(activity[1])
			UndoQueue.POP:
				DoPop(activity[2])
			UndoQueue.UN_POP:
				Unpop(activity[1], activity[2])
	
	print("Executed")
	print()
	emit_signal("new_move")


func DoMove(from: int, to: int):
	print("Move " + str(from) + " " + str(to))
	$"/root/Settings".PlaySfx("Mushroom")

	var path = _astar.get_id_path(from, to)
	$MovePath.global_position = Vector2()
	$MovePath.curve.clear_points()
	for cid in path:
		$MovePath.curve.add_point(cell(cid).center_position())
	$MovePath/PathFollow2D.progress_ratio = 0
	
	var mushroom = cell(from).GetMushroom()
	cell(to).Add(cell(from).PopMushroom())
	_astar.set_point_disabled(from, false)
	_astar.set_point_disabled(to, true)
	
	$MovePath/PathFollow2D/RemoteTransform2D.remote_path = mushroom.get_path()
	mushroom.z_index = $MovePath/PathFollow2D/RemoteTransform2D.z_index
	
	var tween = get_tree().create_tween()
	tween.tween_property($MovePath/PathFollow2D, "progress_ratio", 1,\
			0.3 + path.size()*0.06).set_trans(Tween.TRANS_SINE)
	await tween.finished
	mushroom.z_index = 0


func DoRelocate(from: PackedInt32Array, to: PackedInt32Array):
	print("DoRelocate " + str(from) + " " + str(to))
	for i in range(0, from.size()):
		cell(to[i]).Add(cell(from[i]).PopSpore())
		cell(to[i]).GetSpore().Sprout()


func DoPop(m_cids: PackedInt32Array):
	print("DoPop " + str(m_cids))
	for cid in m_cids:
		var mushroom = cell(cid).GetMushroom()
		var t = mushroom.global_transform
		$VanishingMushrooms.add_child(cell(cid).PopMushroom())
		mushroom.global_transform = t
		mushroom.Pop()
		_astar.set_point_disabled(cid, false)
	emit_signal("mushroom_popped", m_cids.size())


func DoSprout(s_ids: PackedInt32Array, s_cids: PackedInt32Array):
	print("DoSprout " + str(s_ids) + " " + str(s_cids))
	for i in range(0, s_cids.size()):
		var spore = $MushroomGenerator.GetNewMushroom(s_ids[i])
		cell(s_cids[i]).Add(spore)
		spore.Sprout()


func DoGrow(s_cids: PackedInt32Array):
	print("Dogrow " + str(s_cids))
	for cid in s_cids:
		var c = cell(cid)
		if c.HasMushroom():
			c.PopSpore().queue_free()
			continue
		c.GetSpore().Grow()
		_astar.set_point_disabled(cid)


func Ungrow(m_cids: PackedInt32Array):
	print("Ungrow " + str(m_cids))
	for cid in m_cids:
		if cell(cid).HasMushroom():
			cell(cid).GetMushroom().Ungrow()
			_astar.set_point_disabled(cid, false)


func Unsprout(s_cids: PackedInt32Array):
	print("Unsprout " + str(s_cids))
	for cid in s_cids:
		if cell(cid).HasSpore():
			var spore = cell(cid).GetSpore()
			var t = spore.global_transform
			$VanishingMushrooms.add_child(cell(cid).PopSpore())
			spore.global_transform = t
			spore.Unsprout()


func Unpop(m_id: int, m_cids: PackedInt32Array):
	print("Unpop " + str(m_id) + " " + str(m_cids))
	for cid in m_cids:
		var mushroom = $MushroomGenerator.GetNewMushroom(m_id)
		cell(cid).Add(mushroom)
		mushroom.Unpop()
		_astar.set_point_disabled(cid)
	emit_signal("mushroom_popped", -m_cids.size())


func GetSaveData():
	# 0: mushroom_ids
	# 1: mushroom_cell_ids
	# 2: spore_ids
	# 3: spore_cell_ids
	var board_state: Array[PackedInt32Array] = [[], [], [], []]
	
	for c in $Grid.get_children():
		if c.HasMushroom():
			board_state[0].push_back(c.GetMushroom().ID)
			board_state[1].push_back(id(c))
		if c.HasSpore():
			board_state[2].push_back(c.GetSpore().ID)
			board_state[3].push_back(id(c))
	
	return {
		"type": "board",
		"board_state": board_state,
		"uq": uq.GetSaveData(),
		"generator": $MushroomGenerator.GetSaveData()
		}


func LoadSaveData(save_data: Dictionary):
	$MushroomGenerator.LoadSaveData(save_data["generator"])
	
	uq.LoadSaveData(save_data["uq"])
	
	for c in $Grid.get_children():
		c.Clear()
		_astar.set_point_disabled(id(c), false)
		
	var board_state = save_data["board_state"]
	
	DoSprout(board_state[0], board_state[1])
	DoGrow(board_state[1])
	DoSprout(board_state[2], board_state[3])


func _on__item_rect_changed():
	$VanishingMushrooms.scale = $Grid.get_child(0).get_node("Center").scale

