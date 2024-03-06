extends Node

var screen_height
var block_manager
var players = []
var camera
var camera2
var height_label:Label
var tower:Tower
var block_preview
var block_types:Array
var block_randomizer
var time_label
var timer
var effect_bus
var remaining_time
var GameOverScreen
var high_height = 0
var save_file_path = "user://save_game.dat"
var game_over = false
signal replay_pressed
var check_point_drawer
enum GAMEMODE {SINGLEPLAYER, COOP, PVP}
export(GAMEMODE) var gamemode
export(NodePath) var cameraPath
export(NodePath) var camera2Path

func _ready():
	randomize()
	camera = get_node(cameraPath)
	if camera2Path:
		camera2 = get_node(camera2Path)
	screen_height = get_viewport().get_visible_rect().size.y
	block_types = load_block_types()
	for child in get_children():
		if child.is_in_group("Players"):
			players.append(child)
	height_label = $HUD/HeightLabel
	block_preview = $HUD/BlockPreview
	tower = $Tower
	tower.owning_players.append(players[0])
	players[0].tower = tower
	if gamemode == GAMEMODE.COOP:
		tower.owning_players.append(players[1])
		players[1].tower = tower
	if gamemode == GAMEMODE.PVP:
		var tower2 = $Tower2
		players[1].tower = tower2
		tower2.owning_players.append(players[1])
		
	time_label = $HUD/TimeLabel
	timer = $Timer
	timer.start()
	
	block_manager = $BlockManager
	GameOverScreen = $HUD/GameOverScreen
	check_point_drawer = $CheckpointDrawer
	block_randomizer = BlockRandomizer.new(block_types)
	for player in players:
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
	for player in players:
		update_camera(player.tower.height)
		update_player(player.tower.height, player)
		update_height_label(player.tower.height)
		update_time_label()
		
		if (not player.active_block
				or player.active_block.global_position.y > 1000
				) and player.block_spawn_cooldown_ready():
			player.set_active_block(block_manager.spawn_block(player.upcoming_block_queue.pop_front(), player.position))
			player.upcoming_block_queue.append(block_randomizer.get_block_type_for(player))
		update_block_preview(player)

func update_block_preview(player) -> void:
	var temp_instance = player.upcoming_block_queue[0].instance()
	block_preview.update_preview_block(temp_instance)
	temp_instance.queue_free()

func update_height_label(tower_height) -> void:
	height_label.update_height(tower_height)

func update_time_label() -> void:
	remaining_time = max(0, timer.time_left)
	time_label.update_time(remaining_time)

func update_camera(tower_height) -> void:
	var zoom_value = max(min(1+(tower_height/screen_height)*1.3,3),2)
	camera.zoom = lerp(camera.zoom, Vector2(zoom_value, zoom_value), 0.05)
	camera.position.y = lerp(camera.position.y, players[0].position.y + screen_height*0.4*zoom_value, 0.02)

func update_player(tower_height, player) -> void:
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

func _on_Player_checkpoint_reached(player_that_reached_checkpoint):
	add_time()
	player_that_reached_checkpoint.upcoming_block_queue.insert(0, block_randomizer.get_locker_block_for(player_that_reached_checkpoint))

func add_time(): 
	remaining_time += 15
	timer.start(remaining_time)	
	update_time_label()
	
func _on_replay_pressed():
	game_over = false

func _on_Timer_timeout():
	if not game_over:
		timer.stop()
		GameOverScreen.set_height(int(players[0].tower.height))	
	if players[0].tower.height > high_height and not game_over:
		GameOverScreen.set_highest_height(int(players[0].tower.height))
		high_height = int (players[0].tower.height)
	save_game()
	yield(get_tree().create_timer(1.5), "timeout")
	GameOverScreen.visible = true
	get_tree().paused = true
	game_over = true
	