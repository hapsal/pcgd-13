extends Node

var screen_height
var block_manager
var player
var camera:Camera2D
var height_label:Label
var tower:Tower
var tower_height
var timer
var timer_label
var remaining_time: float
var time_to_add_on_height = 10.0 
var height_level = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_height = get_viewport().get_visible_rect().size.y
	block_manager = $BlockManager
	camera = $Camera2D
	player = $Player
	height_label = $HUD/HeightLabel
	tower = $Tower
	timer = $Timer
	timer_label = $HUD/TimerLabel
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tower_height = tower.height
	update_camera()
	update_player()
	update_label()
	check_add_time()	
	update_remaining_time()

	if not player.active_block or player.active_block.is_colliding_with_another_object():
		player.set_active_block(block_manager.spawn_block_at(player.position))
		block_manager.show_next_block_preview()
	

func update_label() -> void:
	height_label.update_height(tower_height)

func format_time(seconds: float) -> String:
	var minutes = int(seconds / 60)
	var seconds_part = int(seconds) % 60
	return str(minutes) + ":" + str(seconds_part).pad_zeros(2)

func update_remaining_time():
	remaining_time = max(0, timer.time_left)
	timer_label.text = "Remaining Time: " + str(format_time(remaining_time))


func update_camera() -> void:
	var zoom_value = max(min(1+(tower_height/screen_height)*1.3,3),2)
	camera.zoom = lerp(camera.zoom, Vector2(zoom_value, zoom_value), 0.05)
	camera.position.y = lerp(camera.position.y, player.position.y + screen_height*0.5*zoom_value, 0.02)

func update_player() -> void:
	player.move_to_height(tower_height)

func check_add_time() -> void:
	var level = int(tower_height/200)
	if level >= height_level:
		add_time()
		height_level += 1

func add_time() -> void:
	remaining_time += 10
	timer_label.text = "Remaining Time: " + str(format_time(remaining_time))
	timer.start(remaining_time + 10)


func _on_Timer_timeout():
	print("Timer Stop")
	get_tree().paused = true

