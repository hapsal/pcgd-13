extends Node

export(String, DIR) var blocks_directory
var block_types:Array
var block_spawn_timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	block_types = load_block_types()
	print(block_types)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	block_spawn_timer += delta
	if block_spawn_timer >= 1.0:
		spawn_block_at($PlayerCursor.transform.origin)
		block_spawn_timer = 0.0

func spawn_block_at(location:Vector2) -> void:
	var new_block = block_types[randi() % (block_types.size() - 1)].instance()
	add_child(new_block)
	new_block.transform.origin = location
	return 




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
