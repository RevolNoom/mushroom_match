class_name UndoQueue


var move_deque: Array[Array] = []

var _cur: int = 0 #current index in move_deque
@export var undo_limit: int = 5:
	set(new_limit):
		if new_limit > undo_limit:
			undo_limit = new_limit
		elif new_limit < undo_limit:
			var less = undo_limit - new_limit
			_cur -= less
			move_deque = move_deque.slice(less)

enum{
	MOVE, #[MOVE, from.x, from.y, to.x, to.y]
	RELOCATE,	#[RELOCATE, from.x, from.y, to.x, to.y]
	GROW,	#[GROW, [m1.x, m1.y, m2.x, m2.y, ...]]
	UN_GROW,
	SPROUT,	#[SPROUT, [m1.id, m2.id,...], [m1.x, m1.y, m2.x, m2.y, ...]]
	UN_SPROUT,
	POP,	#[POP, id, [m1.x, m1.y, m2.x, m2.y,...]]
	UN_POP,
}

func _ready():
	move_deque.resize(undo_limit)
	move_deque.resize(1)
	move_deque[0] = []


func Next():
	_cur = clamp(_cur + 1, 0, move_deque.size() - 1)


func Prev():
	_cur = clamp(_cur - 1, 0, move_deque.size() - 1)
	

func HasNext() -> bool:
	return _cur < move_deque.size() - 1


func HasPrev() -> bool:
	return _cur > 0


func GetActivities() -> Array:
	return move_deque[_cur]


func GetActivitiesUndo() -> Array:
	var actitivies = GetActivities().duplicate(true)
	actitivies.reverse()
	var result = []
	for activity in actitivies:
		match activity[0]:
			MOVE:
				result.push_back([MOVE, activity[3], activity[4], activity[1], activity[2]])
			RELOCATE:
				result.push_back([RELOCATE, activity[2], activity[1]])
			GROW:
				result.push_back([UN_GROW, activity[1]])
			SPROUT:
				result.push_back([UN_SPROUT, activity[2]])
			POP:
				result.push_back([UN_POP, activity[1], activity[2]])
	return result


func PushMove(from: Vector2i, to: Vector2i):
	if HasNext():
		move_deque = move_deque.slice(0, _cur+1)
		
	move_deque.push_back([MOVE, from.x, from.y, to.x, to.y])
	
	if move_deque.size() > undo_limit:
		move_deque.pop_front()
	_cur = move_deque.size() - 1
	


func PushSprout(id: PackedInt32Array, at: Array[Vector2i]):
	move_deque.back().push_back([SPROUT, id, get_ints_array(at)])


func PushGrow(at: Array[Vector2i]):
	move_deque.back().push_back([GROW, get_ints_array(at)])
	

func PushRelocate(from: Vector2i, to: Vector2i):
	move_deque.back().push_back([RELOCATE, from.x, from.y, to.x, to.y])


func PushPop(id: int, at: Array[Vector2i]):
	var command = [POP, id]
	command.append_array(get_ints_array(at))
	move_deque.back().push_back(command)


func GetSaveData() -> Dictionary:
	return {}


func LoadSaveData():
	pass


func get_coords_array(input: PackedInt32Array) -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	for i in range(0, input.size()/2):
		coords.push_back(Vector2i(input[i*2], input[i*2+1]))
	return coords
	
	
func get_ints_array(coords_array)->PackedInt32Array:
	var ints: PackedInt32Array = []
	for i in range(0, coords_array.size()):
		ints.append_array([coords_array[i].x, coords_array[i].y])
	return ints
