extends Node


signal move(from: Vector2i, to: Vector2i)

# TODO: Is AddSpore necessary? Or Sprout is enough?
signal add_spore(id: int, at: Vector2i)
signal remove_spore(at: Vector2i)

signal grow(at: Array[Vector2i])
signal un_grow(at: Array[Vector2i])

signal sprout(ids: PackedInt32Array, at: Array[Vector2i])
signal un_sprout(at: Array[Vector2i])

signal pop(at: Array[Vector2i])
signal un_pop(id: int, at: Array[Vector2i])

signal done_execute

# move_deque[i]: 
# An array of activities that happened during the i-th move 
# move_deque[i][j]: Array
# The j-th activity happened during the i-th move
# An activity has the format of: [TYPE, attributes...]
# e.g.: [MOVE, Vector2i(1, 1), Vector2i(1, 2)] 
var move_deque: Array[Array] = []

# Stack of activities that are still waiting to be animated 
var activity_stack: Array
var _cur: int = 0 #current index in move_deque
@export var undo_limit: int = 5
#@onready var _board = get_parent()


enum Command{
	MOVE,			#[MOVE, from.x, from.y, to.x, to.y]
	
	#[RELOCATE, [from1.x, from1.y, from2.x, from2.y, ...], [to1.x, to2.y,...]]
	RELOCATE,		
	
	#[GROW, [m1.x, m1.y, m2.x, m2.y, ...]]
	GROW,
	UN_GROW,
	
	#[SPROUT, [m1.id, m2.id,...], [m1.x, m1.y, m2.x, m2.y, ...]]
	SPROUT,
	UN_SPROUT,
	
	#[POP, id, [m1.x, m1.y, m2.x, m2.y,...]]
	POP,
	UN_POP,
}


func _ready():
	move_deque.resize(undo_limit)
	move_deque.resize(1)
	move_deque[0] = []


func Undo():
	#Changing order of arguments of activities
	for activity in prev():
		match activity[0]:
			# Change from->to to to->from
			Command.MOVE:
				activity_stack.push_back([Command.MOVE, activity[3], activity[4], activity[1], activity[2]])
			Command.RELOCATE:
				activity_stack.push_back([Command.RELOCATE, activity[2], activity[1]])
			
			Command.GROW:
				activity_stack.push_back([Command.UN_GROW, activity[1]])
				
			Command.SPROUT:
				activity_stack.push_back([Command.UN_SPROUT, activity[2]])
				
			Command.POP:
				activity_stack.push_back([Command.UN_POP, activity[1], activity[2]])
	Execute()


func Redo():
	activity_stack = next()
	activity_stack.reverse()
	Execute()
	

# Execute the next activity
func Execute():
	if activity_stack.size() > 0:
		var activity = activity_stack.pop_back()
		match activity[0]:
			Command.MOVE:
				emit_signal("move", Vector2i(activity[1], activity[2]),\
									Vector2i(activity[3], activity[4]))
			Command.RELOCATE:
				emit_signal("relocate", Vector2i(activity[1], activity[2]),\
										Vector2i(activity[3], activity[4]))
			Command.GROW:
				emit_signal("grow", get_coords_array(activity[1]))
			Command.UN_GROW:
				emit_signal("un_grow", get_coords_array(activity[1]))
				
			Command.SPROUT:
				emit_signal("sprout", activity[1], get_coords_array(activity[2]))
			Command.UN_SPROUT:
				emit_signal("un_sprout", get_coords_array(activity[2]))
				
			Command.POP:
				emit_signal("pop", get_coords_array(activity[2]))
			Command.UN_POP:
				emit_signal("un_pop", activity[1], get_coords_array(activity[2]))
				
	if activity_stack.size() == 0:
		emit_signal("done_execute")

func SetUndoLimit(new_limit: int):
	if new_limit > undo_limit:
		undo_limit = new_limit
	elif new_limit < undo_limit:
		var less = undo_limit - new_limit
		_cur -= less
		move_deque = move_deque.slice(less)


func Move(from: Vector2i, to: Vector2i):
	if _cur < move_deque.size()-1:
		move_deque = move_deque.slice(0, _cur+1)
		
	move_deque.push_back([Command.MOVE, from.x, from.y, to.x, to.y])
	
	if move_deque.size() > undo_limit:
		move_deque.pop_front()
	_cur = move_deque.size() - 1
	
	activity_stack.push_back(move_deque.back())


func Sprout(id: PackedInt32Array, at: Array[Vector2i]):
	move_deque.back().push_back([Command.SPROUT, id, get_ints_array(at)])
	activity_stack.push_front(move_deque.back().back())


func Grow(at: Array[Vector2i]):
	move_deque.back().push_back([Command.GROW, get_ints_array(at)])
	activity_stack.push_front(move_deque.back().back())


func Relocate(from: Vector2i, to: Vector2i):
	move_deque.back().push_back([Command.RELOCATE, from.x, from.y, to.x, to.y])
	activity_stack.push_front(move_deque.back().back())


func Pop(id: int, at: Array[Vector2i]):
	var command = [Command.POP, id]
	command.append_array(get_ints_array(at))
	move_deque.back().push_back(command)
	activity_stack.push_front(move_deque.back().back())


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
	
# Increment current index (if possible)
# Return the array of activities correspond to that index
# return empty array if indexed out of limit
func next() -> Array:
	if _cur == move_deque.size() - 1:
		return []
	_cur += 1
	return cur()
	

# Decrement current index (if possible)
# Return the array of activities correspond to that index
# return empty array if indexed below 0
func prev() -> Array:
	if _cur == 0:
		return []
	_cur -= 1
	return cur()


# Return the array of activities correspond to current index
func cur() -> Array:
	return move_deque[_cur]

