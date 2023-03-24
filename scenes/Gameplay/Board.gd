extends AspectRatioContainer

func _ready():
	AddMushroom(preload("res://scenes/Gameplay/Mushroom.tscn").instantiate(), 0, 0)
	

func AddMushroom(mushroomNode: Sprite2D, row, col):
	var c = cell(row, col)
	c.add_child(mushroomNode)
	mushroomNode.get_rect().position = c.position + c.size/2
	mushroomNode.get_rect().size = c.size


func ResizeMushrooms():
	pass


func cell(row, col) -> Control:
	return $Grid.get_node(str(row * 9 + col))
	
	
func _on_grid_container_resized():
	custom_minimum_size = $Grid.size
