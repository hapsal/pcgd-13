class_name BlockGraph

class Graph:
	var vertices:Array
		
	func _init(var base:Node):
		vertices = [Vertex.new(base, self)]
		
	func add_node_as_vertex(var node:Node) -> Vertex:
		return add_vertex(Vertex.new(node, self))
	
	func connect_vertices(var a:Vertex, var b:Vertex):
		if not a.is_connected_to(b) and vertices.has(a) and vertices.has(b):
			a.connected_vertices.append(b)
			b.connected_vertices.append(a)

	func disconnect_vertices(var a:Vertex, var b:Vertex):
		if a.is_connected_to(b):
			a.connected_vertices.erase(b)
			b.connected_vertices.erase(a)
		return self
			
	func disconnect_all_vertices_from(var vertex:Vertex):
		for connected_vertex in vertex.connected_vertices:
			disconnect_vertices(vertex, connected_vertex)
	
	func add_vertex(var vertex:Vertex) -> Vertex:
		if not vertices.has(vertex):
			vertices.append(vertex)
		return vertex
	
	func erase_node_as_vertex(var node:Node):
		erase_vertex(get_vertex(node))
			
	func erase_vertex(var vertex:Vertex):
		vertices.erase(vertex)
	
	func contains_node(var node:Node) -> bool:
		return get_vertex(node) != null
		
	func get_vertex(var node:Node) -> Vertex:
		for vertex in vertices:
			if vertex.node == node:
				return vertex
		return null

class Vertex:
	var block_graph:Graph
	var node:Node
	var connected_vertices:Array
	
	func _init(var _node:Node, var _block_graph:Graph):
		node = _node
		block_graph = _block_graph
		
	func connect_node_as_vertex_to_this(other_node:Node):
		block_graph.connect_vertices(self, block_graph.get_vertex(other_node))
		
	func disconnect_node_as_vertex_from_this(other_node:Node):
		block_graph.disconnect_vertices(self, block_graph.get_vertex(other_node))
		
	func is_connected_to(vertex:Vertex) -> bool:
		return connected_vertices.has(vertex)
	
	func get_contiguous_vertices(var contiguous_vertices:Array = []) -> Array:
		contiguous_vertices.append(self)
		for vertex in connected_vertices:
			if not contiguous_vertices.has(vertex):
				vertex.get_contiguous_vertices(contiguous_vertices)
		return contiguous_vertices
