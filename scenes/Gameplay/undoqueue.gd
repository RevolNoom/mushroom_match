class_name UndoQueue

@export var undo_limit: int = 5:
	set(new_limit):
		if new_limit > undo_limit:
			undo_limit = new_limit
		elif new_limit < undo_limit:
			var less = undo_limit - new_limit
			_cur -= less
			move_deque = move_deque.slice(less)

var move_deque: Array = []
var _cur: int = -1 #current index in move_deque


# cid: Cell id
enum{
	MOVE = 0, #[MOVE, from.cid, to.cid]
	RELOCATE = 1,	#[RELOCATE, [from1.cid, from2.cid,...], [to1.cid, to2.cid,...])
	GROW = 2,	#[GROW, [m1.cid, m2.cid, ...]]
	UN_GROW = 3,#[UNGROW, [m1.cid, m2.cid, ...]]
	SPROUT = 4,	#[SPROUT, [m1.id, m2.id,...], [m1.cid, m2.cid, ...]]
	UN_SPROUT = 5,#[UNSPROUT, [m1.cid, m2.cid, ...]]
	POP = 6,	#[POP, mid, [m1.cid, m2.cid,...]]
	UN_POP = 7, #[UNPOP, mid, [m1.cid, m2.cid,...]]
}


func Next():
	_cur = clamp(_cur + 1, -1, move_deque.size() - 1)


func Prev():
	_cur = clamp(_cur - 1, -1, move_deque.size() - 1)
	

func HasNext() -> bool:
	return _cur < move_deque.size() - 1


func HasPrev() -> bool:
	return _cur >= 0


func GetActivities() -> Array:
	return move_deque[_cur].duplicate(true)


func GetActivitiesUndo() -> Array:
	var activities = GetActivities()
	activities.reverse()
	var result = []
	for activity in activities:
		match int(activity[0]):
			MOVE:
				result.push_back([MOVE, activity[2], activity[1]])
			RELOCATE:
				result.push_back([RELOCATE, activity[2], activity[1]])
			GROW:
				result.push_back([UN_GROW, activity[1]])
			SPROUT:
				result.push_back([UN_SPROUT, activity[2]])
			POP:
				result.push_back([UN_POP, activity[1], activity[2]])
	return result


func PushMove(from: int, to: int):
	if HasNext():
		move_deque = move_deque.slice(0, _cur+1)
		
	move_deque.push_back([[MOVE, from, to]])
	
	if move_deque.size() > undo_limit:
		move_deque.pop_front()
	_cur = move_deque.size() - 1
	


func PushSprout(ids: PackedInt32Array, cids: PackedInt32Array):
	move_deque.back().push_back([SPROUT, ids, cids])


func PushGrow(cids: PackedInt32Array):
	move_deque.back().push_back([GROW, cids])
	

func PushRelocate(from: PackedInt32Array, to: PackedInt32Array):
	move_deque.back().push_back([RELOCATE, from, to])


func PushPop(mid: int, cids: PackedInt32Array):
	move_deque.back().push_back([POP, mid, cids])


func GetSaveData() -> Dictionary:
	return {
		"move_deque": move_deque,
		"_cur": _cur,
		"undo_limit": undo_limit
	}


func LoadSaveData(save_data: Dictionary):
	var dirty_md = save_data["move_deque"]
	move_deque = []
	for move in range(0, dirty_md.size()):
		move_deque.push_back([])
		for activity in range(0, dirty_md[move].size()):
			move_deque[move].push_back([])
			for element in range(0, dirty_md[move][activity].size()):
				var elem = dirty_md[move][activity][element]
				if typeof(elem) == TYPE_ARRAY:
					move_deque[move][activity].push_back([])
					for sub_elem in elem:
						move_deque[move][activity][element].push_back(int(sub_elem))
				else:
					move_deque[move][activity].push_back(int(elem))
					
	_cur = int(save_data["_cur"])
	undo_limit = int(save_data["undo_limit"])
