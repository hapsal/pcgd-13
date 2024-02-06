extends Node2D

const vertical_distance_above_tower = 400.0
const move_speed = 400.0
const dash_speed = 10000.0
const rotation_speed = 200.0
const horizontal_movement_limit = 200.0
const block_drop_speed = 100.0
const fast_block_drop_speed = 300.0
const double_tap_input_frames = 13
var cursor_sprite:Sprite
var active_block:Block setget set_active_block, get_active_block
var my_tower:Tower
var double_tap_buffer = {
	"move_down": 0,
	"rotate_clockwise": 0,
	"rotate_counter_clockwise": 0
}

func _ready():
	position.y = -vertical_distance_above_tower
	cursor_sprite = $CursorSprite
	
func _process(delta):
	position.x += movement_input() * move_speed * delta
	position.x = clamp(position.x, -horizontal_movement_limit, horizontal_movement_limit)
	active_block.global_position.x = lerp(active_block.global_position.x, global_position.x, 0.5)
	if Input.is_action_pressed("move_down"):
		active_block.global_position.y += fast_block_drop_speed * delta
	else:
		active_block.global_position.y += block_drop_speed * delta
	rotate_active_block(rotation_speed * delta)
	decrement_double_tap_buffer()
	
func move_to_height(var tower_height:float) -> void:
	var previous_position_y = position.y
	position.y = -tower_height - vertical_distance_above_tower
	cursor_sprite.position.y += (previous_position_y - position.y)

func rotate_active_block(rotation_amount):
	if(Input.is_action_pressed("rotate_clockwise") and Input.is_action_pressed("rotate_counter_clockwise")):
		return
	elif(Input.is_action_pressed("rotate_clockwise")):
		double_tap_buffer["rotate_counter_clockwise"] = 0
		if double_tap_buffer["rotate_clockwise"] < 0.5:
			active_block.rotation_degrees += rotation_amount
		if(Input.is_action_just_pressed("rotate_clockwise")):
			if(double_tap_buffer["rotate_clockwise"] > 0):
				active_block.rotation_degrees = int((active_block.rotation_degrees + 90) / 90) * 90
			double_tap_buffer["rotate_clockwise"] = double_tap_input_frames
	elif(Input.is_action_pressed("rotate_counter_clockwise")):
		double_tap_buffer["rotate_clockwise"] = 0
		if double_tap_buffer["rotate_clockwise"] < 0.5:
			active_block.rotation_degrees -= rotation_amount
		if(Input.is_action_just_pressed("rotate_counter_clockwise")):
			if(double_tap_buffer["rotate_counter_clockwise"] > 0):
				active_block.rotation_degrees = int((active_block.rotation_degrees - 90) / 90) * -90
			double_tap_buffer["rotate_counter_clockwise"] = double_tap_input_frames

func movement_input() -> float:
	var velocity = 0.0
	if Input.is_action_pressed("move_right"):
		velocity += 1
	if Input.is_action_pressed("move_left"):
		velocity -= 1
	return velocity

func set_active_block(var new_active_block:Block) -> Block:
	if active_block:
		enable_gravity_for_active_block()
	active_block = new_active_block
	disable_gravity_for_active_block()
	return active_block
	
func get_active_block() -> Block:
	return active_block

func decrement_double_tap_buffer() -> void:
	for registered_input in double_tap_buffer:
		double_tap_buffer[registered_input] -= 1

var active_block_true_gravity_scale:float
func enable_gravity_for_active_block():
	active_block.set_sleeping(false) 
	active_block.gravity_scale = active_block_true_gravity_scale
func disable_gravity_for_active_block():
	active_block.set_sleeping(false)
	active_block_true_gravity_scale = active_block.gravity_scale
	active_block.gravity_scale = 0.0
