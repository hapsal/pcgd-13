extends Block

const SIN_PREIOD = 1.0 / (180.0 / PI)
const BUBBLE_OFFSET_DISTANCE = 32
const LEVELLING_TORQUE = 3
export(NodePath) var bubble_sprite
var bubble
var self_levelling_active = false

func _ready():
	assert(bubble_sprite)
	bubble = get_node(bubble_sprite)
	
func _process(delta):
	var offset = -sin(global_rotation_degrees * SIN_PREIOD) * BUBBLE_OFFSET_DISTANCE
	bubble.offset.x = lerp(bubble.offset.x, offset, 0.2)
	if not self_levelling_active:
		if get_colliding_blocks():
			self_levelling_active = true
	else:
		angular_velocity -= (global_rotation_degrees - stepify(global_rotation_degrees, 180)) * LEVELLING_TORQUE * delta
