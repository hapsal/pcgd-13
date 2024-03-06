extends Node2D

const vertical_distance_above_tower = 600.0
const move_speed = 400.0
const dash_speed = 10000.0
const rotation_speed = 200.0
const default_drop_speed = 100.0
const fast_drop_speed = 300.0
const slam_drop_speed = 700.0
const snap_rotation_cooldown = 0.15
var cursor_sprite:Sprite
var active_block:Block setget set_active_block
var tower:Tower
var upcoming_block_queue = []
var controls:Controls
var seconds_since_snap_rotation = snap_rotation_cooldown
var slamming_block = false
var new_block_cooldown = 0
var checkpoint = 0

func _ready():
	position.y = -vertical_distance_above_tower
	cursor_sprite = $CursorSprite
	controls = Controls.new()
	controls.bind_control("move_down", "move_down")
	controls.bind_control_axis("movement", "move_left", "move_right")
	controls.bind_control_axis("rotation", "rotate_counter_clockwise", "rotate_clockwise")
		
func _process(delta):
	new_block_cooldown -= delta
	controls.poll()
	move_player(delta)
	if active_block:
		move_active_block(delta)
		if active_block.colliding_blocks:
			if active_block.colliding_blocks.size() == 1:
				if active_block.colliding_blocks[0].is_in_group("ActiveBlocks"):
					return
			new_block_cooldown = max(0, new_block_cooldown)
			new_block_cooldown += clamp((-active_block.position.y - tower.height)/200, 0, 2.0)
			clear_active_block()

func move_player(delta):
	match controls.get_state("movement"):
		Controls.ControlState.PRESSED, Controls.ControlState.DOUBLE_TAP:
			position.x += controls.get_direction("movement") * move_speed * delta
	if tower:
		position.x = clamp(position.x, -tower.tower_area.shape.extents.x + tower.position.x, tower.tower_area.shape.extents.x + tower.position.x)
	
func move_active_block(delta):
	active_block.global_position.x = lerp(active_block.global_position.x, global_position.x, 0.5)
	
	match controls.get_state("rotation"):
		Controls.ControlState.DOUBLE_TAP:
			active_block.rotation_degrees = round((active_block.rotation_degrees + 90 *  controls.get_direction("rotation"))/90) * 90
			seconds_since_snap_rotation = 0
		Controls.ControlState.PRESSED:
			if seconds_since_snap_rotation > snap_rotation_cooldown:
				active_block.rotation_degrees += controls.get_direction("rotation") * rotation_speed * delta
	seconds_since_snap_rotation += delta
	
	var drop_motion = Vector2.ZERO
	if slamming_block:
		drop_motion.y += slam_drop_speed * delta
	else:
		match controls.get_state("move_down"):
			Controls.ControlState.PRESSED:
				drop_motion.y += fast_drop_speed * delta
			Controls.ControlState.DOUBLE_TAP:
				slamming_block = true
			_:
				drop_motion.y += default_drop_speed * delta
	
	var result = Physics2DTestMotionResult.new()
	active_block.test_motion(drop_motion, false, 0.00, result)
	if result.collider:
		drop_motion = lerp(drop_motion, result.motion, 0.9)
	active_block.global_position.y  += drop_motion.y
	
signal checkpoint_reached(player)
func new_checkpoint_reached():
	checkpoint += 1
	emit_signal("checkpoint_reached", self)
	
func move_to_height(var tower_height:float) -> void:
	var previous_position_y = position.y
	position.y = -tower_height - vertical_distance_above_tower
	cursor_sprite.position.y += (previous_position_y - position.y)

func clear_active_block():
	enable_gravity_for_active_block()
	active_block.remove_from_group("ActiveBlocks")
	active_block = null
	$"../HitSfx".play()

func set_active_block(var new_active_block:Block) -> Block:
	new_block_cooldown = 0.0
	if active_block:
		clear_active_block()
	active_block = new_active_block
	disable_gravity_for_active_block()
	active_block.add_to_group("ActiveBlocks")
	slamming_block = false
	new_block_cooldown += 1
	return active_block

func block_spawn_cooldown_ready() -> bool:
	return new_block_cooldown <= 0

var active_block_true_gravity_scale:float
func enable_gravity_for_active_block():
	active_block.set_sleeping(false) 
	active_block.gravity_scale = active_block_true_gravity_scale
func disable_gravity_for_active_block():
	active_block.set_sleeping(false)
	active_block_true_gravity_scale = active_block.gravity_scale
	active_block.gravity_scale = 0.0
