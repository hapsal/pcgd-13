tool
extends RigidBody2D
class_name Block, "res://editor_tools/icons/Block.svg"

var collision_objects:Array
var rotation_accumulator: float = 0.0

func _process(delta):
	pass
	
func _ready():
	set_contact_monitor(true)
	contacts_reported = 10
	collision_objects = get_collision_objects()
	continuous_cd = CCD_MODE_CAST_RAY
	
func is_colliding_with_another_object() -> bool:
	return not get_colliding_bodies().empty()

const wrong_collision_object_message = "%s has a CollisionShape2D instead of a CollisionPolygon2D\nBlocks must use CollisionPolygon2D"
func get_collision_objects() -> Array:
	var collision_objects:Array
	var children = get_children()
	for child in children:
		if child is CollisionPolygon2D:
			collision_objects.append(child)
		elif child is CollisionShape2D:
			assert(child is CollisionPolygon2D,wrong_collision_object_message % name)
	return collision_objects
	
func rotate_block(degrees: float) -> void:
	rotation_accumulator += degrees
	rotate(deg2rad(degrees))
