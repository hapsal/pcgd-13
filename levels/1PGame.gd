extends Node

var screen_height
var block_manager
var player
var camera:Camera2D
var height_label:Label
var tower:Tower
var tower_height
var time_label
var timer
var remaining_time
var height_level = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_height = get_viewport().get_visible_rect().size.y
	block_manager = $BlockManager
	camera = $Camera2D
	player = $Player
	height_label = $HUD/HeightLabel
	tower = $Tower
	time_label = $HUD/TimeLabel
	timer = $Timer
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tower_height = tower.height
	
	update_camera()
	update_player()
	update_label()
	update_time_label()
	check_add_time()
	if not player.active_block or player.active_block.is_colliding_with_another_object() or player.active_block.global_position.y > 1000:
		player.set_active_block(block_manager.spawn_block_at(player.position))

func update_label() -> void:
	height_label.update_height(tower_height)

func update_time_label() -> void:
	remaining_time = max(0, timer.time_left)
	time_label.update_time(remaining_time)

func update_camera() -> void:
	var zoom_value = max(min(1+(tower_height/screen_height)*1.3,3),2)
	camera.zoom = lerp(camera.zoom, Vector2(zoom_value, zoom_value), 0.05)
	camera.position.y = lerp(camera.position.y, player.position.y + screen_height*0.5*zoom_value, 0.02)

func update_player() -> void:
	player.move_to_height(tower_height)

func add_time(): 
	remaining_time += 10
	timer.start(remaining_time)	
	update_time_label()
	print("Time Added")

func check_add_time() -> void:
	var level = int(tower_height / 400)
	if level >= height_level:
		add_time()
		height_level += 1

func _on_Timer_timeout():
	get_tree().paused = true
	timer.stop()
