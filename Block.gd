extends RigidBody2D
class_name Block, "res://editor_tools/icons/Block.svg"

var collision_objects:Array

func _ready():
	set_contact_monitor(true)
	contacts_reported = 10
	collision_objects = get_collision_objects()
	
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
