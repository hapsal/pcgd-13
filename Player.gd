extends Node2D

export(float) var vertical_distance_above_tower = 400
export(float) var move_speed = 400
export(float) var rotation_speed = 200
export(float, 0, 400, 1) var horizontal_movement_limit = 200
var cursor_sprite:Sprite
var active_block:Block
var my_tower:Tower

func _ready():
	position.y = -vertical_distance_above_tower
	cursor_sprite = $CursorSprite
	
func _process(delta):
	position.x += movement_input() * move_speed * delta
	position.x = clamp(position.x, -horizontal_movement_limit, horizontal_movement_limit)
	active_block.global_position.x = lerp(active_block.global_position.x, global_position.x, 0.5)
	
	active_block.rotate_block(rotation_input() * rotation_speed * delta)
	
func move_to_height(var tower_height:float) -> void:
	var previous_position_y = position.y
	position.y = -tower_height - vertical_distance_above_tower
	cursor_sprite.position.y += (previous_position_y - position.y)

func movement_input() -> float:
	var velocity = 0.0
	if Input.is_action_pressed("move_right"):
		velocity += 1
	if Input.is_action_pressed("move_left"):
		velocity -= 1
	return velocity

func rotation_input() -> float:
	var rotation_direction = 0.0
	if Input.is_action_pressed("rotate_clockwise"):
		rotation_direction += 1
	if Input.is_action_pressed("rotate_counter_clockwise"):
		rotation_direction -= 1
	return rotation_direction

func set_active_block(var new_active_block:Block) -> Block:
	if active_block:
		active_block.linear_velocity.y = 0
	active_block = new_active_block
	return active_block
