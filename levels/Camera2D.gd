extends Camera2D



# Camera properties
var speed = 200.0
var sensitivity = 0.1
var min_x = -1000
var max_x = 1000
var min_y = -1000
var max_y = 1000
# Process function
func _process(delta):

	# User controls
	var input_movement = Vector2()

	# Keyboard input
	if Input.is_action_pressed("ui_up"):
		input_movement.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_movement.y += 1
	if Input.is_action_pressed("ui_left"):
		input_movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_movement.x += 1

	# Normalize to prevent faster diagonal movement
	input_movement = input_movement.normalized()


	# Apply movement
	offset += input_movement * speed * delta

	# Optional: Keep the camera within specific bounds (adjust as needed)
	var camera_position = global_position
	camera_position.x = clamp(camera_position.x, min_x, max_x)
	camera_position.y = clamp(camera_position.y, min_y, max_y)
	global_position = camera_position
