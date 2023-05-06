extends AspectRatioContainer


signal next_turn
signal add_score(amount)
signal full





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
