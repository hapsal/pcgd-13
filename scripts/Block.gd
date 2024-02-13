extends RigidBody2D
class_name Block, "res://editor_tools/icons/Block.svg"

const DESPAWN_BELOW_THIS_Y_COORD = 1500

var colliding_blocks = []
var effects = []
var joints = {}

# Individual blocks should change these!!
export(int, 0, 10) var rarity # 0 (default) is msot common, bigger numbr == less common
export(int, 0, 10) var difficulty # How difficult is it to build with this block? 0 is easiest

func _ready():
	set_meta("is_block", true)
	set_contact_monitor(true)
	contacts_reported = 10
	continuous_cd = CCD_MODE_CAST_RAY

func _process(_delta):
	update_colliding_blocks()
	if global_position.y > DESPAWN_BELOW_THIS_Y_COORD:
		queue_free()

func update_colliding_blocks():
	colliding_blocks.clear()
	colliding_blocks.append_array(get_jointed_to_blocks())
	for body in get_colliding_bodies():
		if not colliding_blocks.has(body) and body.has_meta("is_block"): # Can't use "is Block" because it would cause a cyclic reference
			colliding_blocks.append(body)

func get_contiguous_blocks(var contiguous_blocks:Array = [], including_self = false) -> Array:
	contiguous_blocks.append(self)
	for body in colliding_blocks:
		if not contiguous_blocks.has(body):
			body.get_contiguous_blocks(contiguous_blocks, true)
	if not including_self:
		contiguous_blocks.erase(self)
	return contiguous_blocks

func lock_with(other_block:Block) -> void:
	if other_block.mode == 3:
		mode = 3
	if not joints.has(other_block):
		var joint = PinJoint2D.new()
		joint.node_a = get_path()
		joint.node_b = other_block.get_path()
		joint.bias = 0.9
		joint.disable_collision = true
		add_child(joint)
		joints[other_block] = joint
	
func unlock_from(other_block:Block) -> void:
	if joints.has(other_block):
		other_block.unlock_from(self)
		joints[other_block].queue_free()

func get_jointed_to_blocks() -> Array:
	var jointed_to_blocks = []
	for joint in joints:
		jointed_to_blocks.append(joint)
	return jointed_to_blocks

func is_colliding_with_another_block() -> bool:
	return not colliding_blocks.empty()
	
func rotate(degrees: float) -> void:
	rotate(deg2rad(degrees))

func set_rotation(degrees: float) -> void:
	rotation = deg2rad(degrees)

func get_rotation() -> float:
	return rad2deg(rotation)
