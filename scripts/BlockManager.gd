extends Node2D
	
func spawn_block(type, location:Vector2) -> Block:
	var new_block = type.instance()
	add_child(new_block)
	new_block.transform.origin = location
	return new_block
