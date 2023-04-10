extends AspectRatioContainer

signal next_turn
signal add_score(amount)
signal full


func _ready():
	$InputProcessor.SetUp()
	$MushroomGenerator.RandomizeGeneratingMushroomSet(7)
	RandomizeInitialBoard($MushroomGenerator.GenerateMushrooms(10))
	AddSpores($MushroomGenerator.GenerateMushrooms(spore_per_turn))
	next_turn_spore = $MushroomGenerator.GenerateMushrooms(spore_per_turn)
	

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
	return $Grid.get_node(str(coordinate.y*$Grid.columns + coordinate.x))


@export var spore_per_turn = 5
var spored_cells = []
var next_turn_spore: Array
func GetNextTurnSpores():
	return next_turn_spore


func AddSpores(spore_list: Array):
	var cells = $Grid.get_children()
	cells.shuffle()

	for c in cells:
		if spore_list.size() == 0:
			return
		if c.IsEmpty():
			c.AddSpore(spore_list.pop_back())
			spored_cells.append(c)
	

# Return cell coordinate in [x, y]
func coord(board_cell: Cell) -> Vector2i:
	var id = int(board_cell.name.substr(0))
	return Vector2i(id % $Grid.columns, id / $Grid.columns)
	
	
func _on_grid_container_resized():
	custom_minimum_size = $Grid.size


func _on_input_processor_mushroom_moved_to(new_cell):
	if PopLines(coord(new_cell)) == 0:
		GrowSpores()
		AddSpores(next_turn_spore)
		next_turn_spore = $MushroomGenerator.GenerateMushrooms(spore_per_turn)
		emit_signal("next_turn")
		

# TODO: Randomize Mushroom type
func RandomizeInitialBoard(init_mushrooms: Array[Mushroom]):
	var c = $Grid.get_children()
	c.shuffle()
	for i in range(0, init_mushrooms.size()):
		c[i].AddMushroom(init_mushrooms[i])
		
	for i in c.slice(0, init_mushrooms.size(), 1, true):
		if i.HasMushroom():
			PopLines(coord(i))


# Pop lines of mushrooms, with line searching starts from startingCells
# All mushrooms have been grown before searching is initiated
# Return amount of score increased
func PopLines(startingCell: Vector2i) -> int:
	
	#Note: Color_canvas is actually transposed Board
	# Actually, its transposition depends on how you lay it out
	# As long as you are consistent in indexing rule, you are fine
	var color_canvas=CreateCanvas(0)
	
	var c = startingCell
	
	var stack = [c]
	
	while stack.size():
		var startPoint = stack.pop_back()
		for direction in [	Vector2i(0, 1),	# Horizontals
							Vector2i(1, 1),	# Diagonal /
							Vector2i(1, 0),	# Vertical
							Vector2i(1,-1)]:# Diagonal \
			if count_dir(cell(startPoint), direction) >= 5:
				color_canvas[c.x][c.y] = 1
				stack.append_array(paint_dir(cell(startPoint), direction, color_canvas))

	return pop_lines(color_canvas)


func pop_lines(color_canvas: Array) -> int:
	var count = 0
	for i in range(0, 9):
		for j in range(0, 9):
			if color_canvas[i][j] == 1:
				count+=1
				var mshr = cell(Vector2i(i, j)).GetMushroom()
				mshr.PlayAnim("diminish")
				mshr.connect("anim_finished", free_mushroom.bind(cell(Vector2i(i, j))), CONNECT_ONE_SHOT)
				
	var score = count * (count-4)
	emit_signal("add_score", score)
	return score


func free_mushroom(_mushroom: Mushroom, _anim_name: String, where: Cell):
	where.PopMushroom().queue_free()


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


func GrowSpores():
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
	AddSpores(spores_to_relocate)


func GetScreenshot() -> ImageTexture:
	var rect = $Grid.get_rect()
	rect.position = $Grid.get_screen_position()
	return ImageTexture.create_from_image(get_viewport().get_texture().get_image().get_region(rect))
