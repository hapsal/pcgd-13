extends Area2D
class_name Tower 

var tower_origin_blocks:Array
var blocks_in_tower:Array
var tower_area:CollisionShape2D
var owning_player:Node
var height:float
var peak:Vector2
var bee

func _ready():
	tower_origin_blocks.append($Base)
	bee = $Bee
	bee.play("Buzz")
	tower_area = $TowerArea
	
func _process(_delta):
	update_blocks_in_tower()
	peak = get_peak()
	height = -peak.y
	bee.position.y = lerp(bee.position.y, -height, 0.3)
	update()

func _draw():
	draw_line(Vector2(-tower_area.shape.extents.x, bee.position.y), Vector2(tower_area.shape.extents.x, bee.position.y), Color.coral, 4)

func update_blocks_in_tower() -> Array:
	var bodies_inside_tower_area = get_overlapping_bodies()
	for body in bodies_inside_tower_area:
		if (body is Block) and (body.mode == 3) and (not tower_origin_blocks.has(body)):
			tower_origin_blocks.append(body)
	blocks_in_tower.clear()
	var tower_origins_to_check = tower_origin_blocks
	for tower_origin in tower_origins_to_check:
		blocks_in_tower.append(tower_origin)
		for block in tower_origin.get_contiguous_blocks():
			if not blocks_in_tower.has(block) and bodies_inside_tower_area.has(block):
				blocks_in_tower.append(block)
				if block.mode == 3:
					tower_origin_blocks.append(block)
				# If an origin is contiguous to another origin we don't need to
				# check it as it's contiguous blocks are a subset of this
				# origin's contiguous blocks
				if tower_origins_to_check.has(block):
					tower_origins_to_check.erase(block)
	return blocks_in_tower

func get_peak() -> Vector2:
	var centre_of_highest_block = Vector2.ZERO
	for block in blocks_in_tower:
		block.set_collision_layer_bit(1, true)
		if centre_of_highest_block.y > block.position.y:
			centre_of_highest_block = block.position
	var highest_peak_found = centre_of_highest_block
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(Vector2(-tower_area.shape.extents.x, highest_peak_found.y), Vector2(tower_area.shape.extents.x, highest_peak_found.y), [tower_area], 0b10, 1)
	while result:
		highest_peak_found = result["position"]
		result =  space_state.intersect_ray(Vector2(-tower_area.shape.extents.x, highest_peak_found.y-1), Vector2(tower_area.shape.extents.x, highest_peak_found.y-1), [tower_area], 0b10, 1)
	return highest_peak_found

func _on_Tower_body_entered(body):
	if body is Block and not blocks_in_tower.has(body):
		blocks_in_tower.append(body)

func _on_Tower_body_exited(body):
	if body is Block and blocks_in_tower.has(body):
		blocks_in_tower.erase(body)
