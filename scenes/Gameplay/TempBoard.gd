extends AspectRatioContainer


signal next_turn
signal add_score(amount)
signal full




func GetSaveData():
	var canvas = CreateCanvas(0)
	for cll in $Grid.get_children():
		var c = coord(cll)
		if cll.HasMushroom():
			canvas[c.x][c.y] = cll.GetMushroom().ID
		elif cll.HasSpore():
			canvas[c.x][c.y] = - cll.GetSpore().ID
	
	var nts = []
	for i in next_turn_spore:
		nts.push_back(i.ID)
		
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
	
	spored_cells.clear()
	for i in range(0, 9):
		for j in range(0, 9):
			var c = cell(Vector2i(i, j))
			c.Clear()
			
			var id = save_data["canvas"][i][j]
			if id < 0:
				c.AddSpore($MushroomGenerator.GetNewMushroom(-id))
				spored_cells.push_back(c)
			elif id > 0:
				c.AddMushroom($MushroomGenerator.GetNewMushroom(id))
				
	# TODO: Freeing is not my concern for now
	next_turn_spore.clear()
	for id in save_data["next_turn_spore"]:
		next_turn_spore.push_back($MushroomGenerator.GetNewMushroom(id))
	


func _on_command_center_grow(at: Array[Vector2i]):
	for coordinate in at:
		var c = cell(coordinate)
		c.GetSpore()
		c.Grow()
	pass # Replace with function body.


func _on_command_center_move(from: Vector2i, to: Vector2i):
	$InputProcessor.Move(from, to)
	# TODO: Wait sequencially for all mushrooms to finish animate
	# Only then, we will start next activity


func _on_command_center_pop(at: Array[Vector2i]):
	for i in at:
		cell(i).GetMushroom().Pop()
	# TODO: Wait sequencially for all mushrooms to finish animate
	# Only then, we will start next activity


func _on_command_center_relocate(from: Vector2i, to: Vector2i):
	# TODO: Make new anim that grows from 0 to full grown
	pass # Replace with function body.


func _on_command_center_sprout(ids: PackedInt32Array, at: Array[Vector2i]):
	for i in range(0, ids.size()):
		var c = cell(at[i])
		var m = $MushroomGenerator.GetNewMushroom(ids[i])
		c.Add(m)
		m.Sprout()
	# TODO: Wait sequencially for all mushrooms to finish animate
	# Only then, we will start next activity


func _on_command_center_un_grow(at: Array[Vector2i]):
	for i in at:
		cell(i).GetMushroom().Ungrow()
	# TODO: Wait sequencially for all mushrooms to finish animate
	# Only then, we will start next activity


func _on_command_center_un_pop(id: int, at: Array[Vector2i]):
	for i in at:
		var m = $MushroomGenerator.GetNewMushroom(id)
		cell(i).Add(m)
		m.Unpop()
	# TODO: Wait sequencially for all mushrooms to finish animate
	# Only then, we will start next activity


func _on_command_center_un_sprout(at: Array[Vector2i]):
	for i in at:
		cell(i).GetSpore().Unsprout()
	# TODO: Wait sequencially for all mushrooms to finish animate
	# Only then, we will start next activity
