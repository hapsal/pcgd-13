extends Node

var screen_height
var block_manager
var player
var camera:Camera2D
var height_label:Label
var tower:Tower
var block_preview_sprite
var block_types:Array
var block_randomizer

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_height = get_viewport().get_visible_rect().size.y
	block_types = load_block_types()
	camera = $Camera2D
	player = $Player
	height_label = $HUD/HeightLabel
	block_preview_sprite = $HUD/BlockPreview/SpriteContainer/Sprite
	tower = $Tower
	player.tower = tower
	block_manager = $BlockManager
	block_randomizer = BlockRandomizer.new(block_types)
	assert(camera and player and height_label and block_preview_sprite and tower and block_manager and block_types.size() > 0)
	while player.upcoming_block_queue.size() < 5:
		player.upcoming_block_queue.append(block_randomizer.get_block_type_for(player))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_camera(player.tower.height)
	update_player(player.tower.height)
	update_height_label(player.tower.height)
	
	if not player.active_block or player.active_block.is_colliding_with_another_object() or player.active_block.global_position.y > 1000:
		player.set_active_block(block_manager.spawn_block(player.upcoming_block_queue.pop_front(), player.position))
		player.upcoming_block_queue.append(block_randomizer.get_block_type_for(player))
	
	update_block_preview()

func update_block_preview() -> void:
	var temp_instance = player.upcoming_block_queue[0].instance()
	block_preview_sprite.texture = temp_instance.get_node("Sprite").texture
	temp_instance.queue_free()

func update_height_label(tower_height) -> void:
	height_label.update_height(tower_height)

func update_camera(tower_height) -> void:
	var zoom_value = max(min(1+(tower_height/screen_height)*1.3,3),2)
	camera.zoom = lerp(camera.zoom, Vector2(zoom_value, zoom_value), 0.05)
	camera.position.y = lerp(camera.position.y, player.position.y + screen_height*0.5*zoom_value, 0.02)

func update_player(tower_height) -> void:
	player.move_to_height(tower_height)

func load_block_types() -> Array:
	var types = []
	var dir = Directory.new()
	dir.open("res://blocks")
	dir.list_dir_begin()
	var file_name = dir.get_next()	
	while file_name != "":
		if file_name.get_extension() == "tscn":
			var packed_scene = load("res://blocks" + "/" + file_name)
			types.append(packed_scene)
		file_name = dir.get_next()
	dir.list_dir_end()
	return types
