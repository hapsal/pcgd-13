extends Node2D

var blocks_container

func _ready():
	blocks_container = $BlocksContainer
	
func spawn_block(type, location:Vector2) -> Block:
	var new_block = type.instance()
	blocks_container.add_child(new_block)
	new_block.transform.origin = location
	return new_block
