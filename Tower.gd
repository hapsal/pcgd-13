extends Area2D
class_name Tower 

var base:Node2D
var tower_area:CollisionShape2D
var block_graph:BlockGraph.Graph
var owning_player:Node
var height:float

func _process(_delta):
	height = get_tower_height()
	update()

func _draw():
	draw_line(Vector2(-tower_area.shape.extents.x, get_tower_peak().y), Vector2(tower_area.shape.extents.x, get_tower_peak().y), Color.coral, 5)

func _ready():
	base = $Base
	tower_area = $TowerArea
	block_graph = BlockGraph.Graph.new(base)
	#assert(collision_layer != 0)

func get_tower_height() -> float:
	return -get_tower_peak().y

func get_tower_peak() -> Vector2:
	var tower = []
	for contiguous_vertex in block_graph.get_vertex(base).get_contiguous_vertices():
		if contiguous_vertex.node is Block and contiguous_vertex.node.is_colliding_with_another_object():
			tower.append(contiguous_vertex.node)
	var centre_of_highest_block = Vector2.ZERO
	for block in tower:
		block.set_collision_layer_bit(1, true)
		if centre_of_highest_block.y > block.position.y:
			centre_of_highest_block = block.position
	var space_state = get_world_2d().direct_space_state
	var peak = centre_of_highest_block
	var result = space_state.intersect_ray(Vector2(-tower_area.shape.extents.x, peak.y), Vector2(tower_area.shape.extents.x, peak.y), [self], 0b10, 1)
	while result:
		peak = result["position"]
		result =  space_state.intersect_ray(Vector2(-tower_area.shape.extents.x, peak.y-1), Vector2(tower_area.shape.extents.x, peak.y-1), [self], 0b10, 1)
	return peak

func _on_Tower_body_entered(body):
	if body is Block:
		var vertex = block_graph.add_node_as_vertex(body)
		body.connect("body_entered", vertex, "connect_node_as_vertex_to_this")
		body.connect("body_exited", vertex, "disconnect_node_as_vertex_from_this")

func _on_Tower_body_exited(body):
	var vertex = block_graph.get_vertex(body)
	body.disconnect("body_entered", vertex, "connect_node_as_vertex_to_this")
	body.disconnect("body_exited", vertex, "disconnect_node_as_vertex_from_this")
	block_graph.disconnect_all_vertices_from(vertex)
	block_graph.erase_vertex(vertex)
