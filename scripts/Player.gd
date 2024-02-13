extends Node2D

const vertical_distance_above_tower = 400.0
const move_speed = 400.0
const dash_speed = 10000.0
const rotation_speed = 200.0
const horizontal_movement_limit = 200.0
const default_drop_speed = 100.0
const fast_drop_speed = 300.0
const slam_drop_speed = 1000.0
const snap_rotation_cooldown = 0.15
var cursor_sprite:Sprite
var active_block:Block setget set_active_block
var tower:Tower
var upcoming_block_queue = []
var controls:Controls
var seconds_since_snap_rotation = snap_rotation_cooldown
var slamming_block = false

func _ready():
	position.y = -vertical_distance_above_tower
	cursor_sprite = $CursorSprite
	controls = Controls.new()
	controls.bind_control("move_down")
	controls.bind_control_axis("movement", "move_left", "move_right")
	controls.bind_control_axis("rotation", "rotate_counter_clockwise", "rotate_clockwise")
	
func _process(delta):
	controls.poll()
	
	match controls.get_state("movement"):
		Controls.ControlState.PRESSED, Controls.ControlState.DOUBLE_TAP:
			position.x += controls.get_direction("movement") * move_speed * delta
	position.x = clamp(position.x, -horizontal_movement_limit, horizontal_movement_limit)
	active_block.global_position.x = lerp(active_block.global_position.x, global_position.x, 0.5)
	
	match controls.get_state("rotation"):
		Controls.ControlState.DOUBLE_TAP:
			active_block.rotation_degrees = round((active_block.rotation_degrees + 90 *  controls.get_direction("rotation"))/90) * 90
			seconds_since_snap_rotation = 0
		Controls.ControlState.PRESSED:
			if seconds_since_snap_rotation > snap_rotation_cooldown:
				active_block.rotation_degrees += controls.get_direction("rotation") * rotation_speed * delta
	seconds_since_snap_rotation += delta
	
	if slamming_block:
		active_block.global_position.y += slam_drop_speed * delta
	else:
		match controls.get_state("move_down"):
			Controls.ControlState.PRESSED:
				active_block.global_position.y += fast_drop_speed * delta
			Controls.ControlState.DOUBLE_TAP:
				slamming_block = true
			_:
				active_block.global_position.y += default_drop_speed * delta
	

	
func move_to_height(var tower_height:float) -> void:
	var previous_position_y = position.y
	position.y = -tower_height - vertical_distance_above_tower
	cursor_sprite.position.y += (previous_position_y - position.y)

func set_active_block(var new_active_block:Block) -> Block:
	if active_block:
		enable_gravity_for_active_block()
	active_block = new_active_block
	disable_gravity_for_active_block()
	slamming_block = false
	return active_block

var active_block_true_gravity_scale:float
func enable_gravity_for_active_block():
	active_block.set_sleeping(false) 
	active_block.gravity_scale = active_block_true_gravity_scale
func disable_gravity_for_active_block():
	active_block.set_sleeping(false)
	active_block_true_gravity_scale = active_block.gravity_scale
	active_block.gravity_scale = 0.0
