@tool
extends Node3D

const SelectionMode = preload("../utils/selection_mode.gd")

var _edited_node = null
var edited_node :
	get: return _edited_node
	set(n):
		if n == _edited_node:
			return
		if _edited_node:
			_edited_node.transform_updated.disconnect(self._on_transform_updated)
			_edited_node.ply_mesh.mesh_updated.disconnect(self._on_mesh_updated)
		_edited_node = n
		if _edited_node:
			_edited_node.transform_updated.connect(self._on_transform_updated)
			_edited_node.ply_mesh.mesh_updated.connect(self._on_mesh_updated)
			transform = _edited_node.global_transform
		render()

var _is_visible = true
var is_visible:
	get: return _is_visible
	set(val):
		_is_visible = val
		if _is_visible:
			show()
		else:
			hide()

var plugin = null

var _mode = SelectionMode.MESH
var mode:
	get: return _mode
	set(m):
		if _mode == m:
			return
		_mode = m
		render()

const FaceScene = preload("./face.tscn")
const EdgeScene = preload("./edge.tscn")
const VertexScene = preload("./vertex.tscn")

func clear_children():
	for n in get_children():
		n.queue_free()

func _on_mesh_updated():
	var expected_children = 0
	match mode:
		SelectionMode.FACE:
			expected_children = edited_node.ply_mesh.face_count()
		SelectionMode.EDGE:
			expected_children = edited_node.ply_mesh.edge_count()
		SelectionMode.VERTEX:
			expected_children = edited_node.ply_mesh.vertex_count()

	var current_children = get_child_count()
	if expected_children > current_children:
		for i in range(current_children, expected_children):
			match mode:
				SelectionMode.FACE:
					instance_face(i)
				SelectionMode.EDGE:
					instance_edge(i)
				SelectionMode.VERTEX:
					instance_vertex(i)
	elif expected_children < current_children:
		for i in range(expected_children, current_children):
			get_child(i).queue_free()

func _on_transform_updated():
	self.transform = edited_node.global_transform

func instance_face(idx):
	var sc = FaceScene.instantiate()
	sc.name = "face_%s" % [idx]
	sc.face_idx = idx
	sc.ply_mesh = edited_node.ply_mesh
	sc.plugin = plugin
	add_child(sc)

func render():
	match mode:
		SelectionMode.MESH:
			clear_children()
		SelectionMode.FACE:
			render_faces()
		SelectionMode.EDGE:
			render_edges()
		SelectionMode.VERTEX:
			render_vertices()

func render_faces():
	clear_children()
	if not edited_node:
		return 
	for idx in range(edited_node.ply_mesh.face_count()):
		instance_face(idx)

func instance_edge(idx):
	var sc = EdgeScene.instantiate()
	sc.name = "edge_%s" % [idx]
	sc.edge_idx = idx
	sc.ply_mesh = edited_node.ply_mesh
	sc.plugin = plugin
	add_child(sc)

func render_edges():
	clear_children()
	if not edited_node:
		return
	for idx in range(edited_node.ply_mesh.edge_count()):
		instance_edge(idx)

func instance_vertex(idx):
	var v = edited_node.ply_mesh.vertexes[idx]
	var sc = VertexScene.instantiate()
	sc.name = "vertex_%s" % [idx]
	sc.vertex_idx = idx
	sc.ply_mesh = edited_node.ply_mesh
	sc.transform.origin = v
	sc.plugin = plugin
	add_child(sc)

func render_vertices():
	clear_children()
	for idx in range(edited_node.ply_mesh.vertex_count()):
		instance_vertex(idx)
