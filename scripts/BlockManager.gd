extends Node2D

export(String, DIR) var blocks_directory = "res://blocks"
var block_types:Array
var blocks_container

func _ready():
	block_types = load_block_types()
	blocks_container = $BlocksContainer

func spawn_block_at(location:Vector2) -> Block:
	var new_block = block_types[randi() % (block_types.size())].instance()
	blocks_container.add_child(new_block)
	new_block.transform.origin = location
	return new_block

func get_tower_height() -> float:
	return -get_tower_peak().y

func get_tower_peak() -> Vector2:
	var approximate_height = approximate_tower_peak()
	return find_exact_peak(approximate_height)

func approximate_tower_peak() -> Vector2:
	var centre_of_highest_block = Vector2.ZERO
	for block in blocks_container.get_children():
		if block.is_colliding_with_another_object(): # (Hacky) Heuristic of if the block is in the tower
			if block.transform.origin.y < centre_of_highest_block.y:
				centre_of_highest_block = block.transform.origin
	return centre_of_highest_block

func find_exact_peak(var minimum_peak:Vector2 = Vector2.ZERO) -> Vector2:
	var space_state = get_world_2d().direct_space_state
	var peak = minimum_peak
	var result = space_state.intersect_ray(Vector2(-300, peak.y), Vector2(300, peak.y), [self], 1)
	while result:
		peak = result["position"]
		result =  space_state.intersect_ray(Vector2(-300, peak.y-1), Vector2(300, peak.y-1), [self], 1)
	return peak

func load_block_types() -> Array:
	var types = []
	var dir = Directory.new()
	dir.open(blocks_directory)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.get_extension() == "tscn":
			var packed_scene = load(blocks_directory + "/" + file_name)
			types.append(packed_scene)
		file_name = dir.get_next()
	dir.list_dir_end()
	return types