extends Area2D
class_name Tower 

var block_tower:Array
var base:Node2D
var tower_area:CollisionShape2D
var block_graph:BlockGraph.Graph
var owning_player:Node
var height:float
var peak:Vector2

func _process(_delta):
	block_tower = get_tower()
	peak = get_peak()
	height = -peak.y
	update()

func _draw():
	draw_line(Vector2(-tower_area.shape.extents.x, peak.y), Vector2(tower_area.shape.extents.x, peak.y), Color.coral, 5)

func _ready():
	base = $Base
	tower_area = $TowerArea
	block_graph = BlockGraph.Graph.new(base)
	#assert(collision_layer != 0)

func get_tower() -> Array:
	var tower = []
	for contiguous_vertex in block_graph.get_vertex(base).get_contiguous_vertices():
		if contiguous_vertex.node is Block and contiguous_vertex.node.is_colliding_with_another_object():
			tower.append(contiguous_vertex.node)
	return tower

func get_peak() -> Vector2:
	var centre_of_highest_block = base.position
	for block in block_tower:
		block.set_collision_layer_bit(1, true)
		if centre_of_highest_block.y > block.position.y:
			centre_of_highest_block = block.position
	var highest_peak_found = centre_of_highest_block
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(Vector2(-tower_area.shape.extents.x, highest_peak_found.y), Vector2(tower_area.shape.extents.x, highest_peak_found.y), [self], 0b10, 1)
	while result:
		highest_peak_found = result["position"]
		result =  space_state.intersect_ray(Vector2(-tower_area.shape.extents.x, highest_peak_found.y-1), Vector2(tower_area.shape.extents.x, highest_peak_found.y-1), [self], 0b10, 1)
	return highest_peak_found

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
