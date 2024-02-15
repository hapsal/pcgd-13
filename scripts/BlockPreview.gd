extends Panel

func update_preview_block(new_block:Block):
	for sprite in $SpriteContainer.get_children():
		sprite.queue_free()
	for child in new_block.get_children():
		if child is Sprite:
			$SpriteContainer.add_child(create_preview_sprite(child))
			
func create_preview_sprite(source_sprite:Sprite) -> Sprite:
	var sprite = source_sprite.duplicate()
#	sprite.z_index = z_index
#	sprite.texture = texture
	return sprite
