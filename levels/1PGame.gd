extends Node

var screen_height
var block_manager
var player_cursor
var camera:Camera2D
export(bool) var spawn_blocks
var block_spawn_timer = 0.0
var tower_height = 0
var active_block:Block

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_height = get_viewport().get_visible_rect().size.y
	block_manager = $BlockManager
	camera = $Camera2D
	player_cursor = $PlayerCursor

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tower_height = block_manager.get_tower_height()
	block_spawn_timer += delta
	if not active_block or active_block.is_colliding_with_another_object():
		active_block = block_manager.spawn_block_at(player_cursor.position)
	update_camera()
	update_cursor()
	update_label()

func update_label():
	var label_node = $Height  # Replace "Label" with the actual name of your Label node
	label_node.text = "Tower Height: " + str(round(tower_height))
	label_node.rect_position.y = lerp(player_cursor.position.y, camera.get_camera_screen_center().y - screen_height*0.5*camera.zoom.y + 50, 1)


func update_camera() -> void:
	camera.position.y = lerp(camera.position.y, -tower_height - screen_height/2 + 50, 0.02)
	var zoom_value = max(min(1+(tower_height/screen_height),2),1)
	#camera.zoom = lerp(camera.zoom, Vector2(zoom_value, zoom_value), 0.05)

func update_cursor() -> void:
	player_cursor.position.y = lerp(player_cursor.position.y, camera.get_camera_screen_center().y - screen_height*0.5*camera.zoom.y + 50, 1)
