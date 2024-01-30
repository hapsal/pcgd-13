extends Node2D

var blocks:Array
export(String, DIR) var blocks_directory = "res://blocks"
var block_types:Array
var rotation_speed = 0.01  # Adjust this as needed
var last_spawned_block: Block  # Variable to keep track of the last spawned block

# Called when the node enters the scene tree for the first time.
func _process(delta):
	if Input.is_action_pressed("rotate_counter_clockwise"):
		last_spawned_block.rotate_block(-rotation_speed)
	# Check for user input to rotate clockwise
	if Input.is_action_pressed("rotate_clockwise"):
		last_spawned_block.rotate_block(rotation_speed)
		
		
func _ready():
	block_types = load_block_types()
	print(block_types)

func rotate_last_spawned_block(angle: float) -> void:
	if last_spawned_block:
		last_spawned_block.rotate_block(angle)
		
func spawn_block_at(location:Vector2) -> Block:
	var new_block = block_types[randi() % (block_types.size())].instance()
	add_child(new_block)
	new_block.transform.origin = location
	last_spawned_block = new_block
	return new_block

func get_tower_height() -> float:
	var center_of_highest_block = 0
	for block in get_children():
		if block.is_colliding_with_another_object(): # (Hacky) Heuristic of if the block is in the tower
			if block.transform.origin.y < center_of_highest_block:
				center_of_highest_block = block.transform.origin.y
	return -center_of_highest_block

func load_block_types() -> Array:
	var types:Array
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
