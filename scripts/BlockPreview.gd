extends Panel

func update_preview_block(new_block:Block):
	for sprite in $SpriteContainer.get_children():
		sprite.queue_free()
	for child in new_block.get_children():
		if child is Sprite:
			$SpriteContainer.add_child(create_preview_sprite(child.texture, child.z_index))
			
func create_preview_sprite(texture, z_index:int) -> Sprite:
	var sprite = Sprite.new()
	sprite.z_index = z_index
	sprite.texture = texture
	return sprite
