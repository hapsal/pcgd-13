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
var time_label
var timer
var remaining_time
var height_level = 1
var GameOverScreen
var high_height = 0
var save_file_path = "user://save_game.dat"
var game_over = false
signal replay_pressed

func _ready():
	screen_height = get_viewport().get_visible_rect().size.y
	block_types = load_block_types()
	camera = $Camera2D
	player = $Player
	height_label = $HUD/HeightLabel
	block_preview_sprite = $HUD/BlockPreview/SpriteContainer/Sprite
	tower = $Tower
	time_label = $HUD/TimeLabel
	timer = $Timer
	timer.start()
	player.tower = tower
	block_manager = $BlockManager
	GameOverScreen = $HUD/GameOverScreen
	block_randomizer = BlockRandomizer.new(block_types)
	while player.upcoming_block_queue.size() < 5:
		player.upcoming_block_queue.append(block_randomizer.get_block_type_for(player))
	$BackgroundMusic.play(0)
	GameOverScreen.connect("replay_pressed", self, "_on_replay_pressed")
	
	# loading high score from file system
	var save_file = File.new()
	
	if save_file.open(save_file_path, File.READ) == OK:
		high_height = save_file.get_32()
		GameOverScreen.set_highest_height(int(high_height))
		print("Loaded high_height from file:", high_height)
		save_file.close()
	else:
		high_height = 0
		save_game()
		print("File created or failed to load, initializing with default high_height.")

	

func save_game():
	var file = File.new()
	if file.open(save_file_path, File.WRITE) == OK:
		file.store_32(high_height)
		file.close()
		print("Game saved successfully")
	else:
		print("Failed to save game")

func _process(_delta):
	update_camera(player.tower.height)
	update_player(player.tower.height)
	update_height_label(player.tower.height)
	update_time_label()
	check_add_time(player.tower.height)

	
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

func update_time_label() -> void:
	remaining_time = max(0, timer.time_left)
	time_label.update_time(remaining_time)

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

func add_time(): 
	remaining_time += 60
	timer.start(remaining_time)	
	update_time_label()
	print("Time Added")

func check_add_time(tower_height) -> void:
	var level = int(tower_height / 400)
	if level >= height_level:
		add_time()
		height_level += 1

func _on_replay_pressed():
	game_over = false

func _on_Timer_timeout():
	game_over = true
	timer.stop()
	GameOverScreen.set_height(int(player.tower.height))	
	if player.tower.height > high_height:
		GameOverScreen.set_highest_height(int(player.tower.height))
		high_height = int (player.tower.height)
	save_game()
	yield(get_tree().create_timer(1.5), "timeout")
	GameOverScreen.visible = true
	
