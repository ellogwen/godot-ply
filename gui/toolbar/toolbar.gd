@tool
extends Control

const SelectionMode = preload("../../utils/selection_mode.gd")

signal generate_plane
signal generate_cube
signal set_face_surface(s)

signal selection_mode_changed(mode)
signal transform_mode_changed(mode)

@onready var transform_toggle = $TransformToggle

@onready var selection_mesh   = $Mesh
@onready var selection_face   = $Face
@onready var selection_edge   = $Edge
@onready var selection_vertex = $Vertex

@onready var mesh_tools = $MeshTools
@onready var mesh_generators = $MeshTools/Generators

@onready var face_tools = $FaceTools
@onready var face_select_loop_1 = $FaceTools/FaceLoop1
@onready var face_select_loop_2 = $FaceTools/FaceLoop2
@onready var face_extrude       = $FaceTools/Extrude
@onready var face_connect       = $FaceTools/Connect

@onready var face_set_shape_1 = $"FaceTools/Surfaces/1"
@onready var face_set_shape_2 = $"FaceTools/Surfaces/2"
@onready var face_set_shape_3 = $"FaceTools/Surfaces/3"
@onready var face_set_shape_4 = $"FaceTools/Surfaces/4"
@onready var face_set_shape_5 = $"FaceTools/Surfaces/5"
@onready var face_set_shape_6 = $"FaceTools/Surfaces/6"
@onready var face_set_shape_7 = $"FaceTools/Surfaces/7"
@onready var face_set_shape_8 = $"FaceTools/Surfaces/8"
@onready var face_set_shape_9 = $"FaceTools/Surfaces/9"

@onready var edge_tools = $EdgeTools
@onready var edge_select_loop = $EdgeTools/SelectLoop
@onready var edge_cut_loop  = $EdgeTools/CutLoop
@onready var edge_subdivide = $EdgeTools/Subdivide
@onready var edge_collapse = $EdgeTools/Collapse

@onready var vertex_tools = $VertexTools

func _ready():
	transform_toggle.toggled.connect(self._update_transform_toggle)
	selection_mesh.toggled.connect(self._update_selection_mode.bind(SelectionMode.MESH))
	selection_face.toggled.connect(self._update_selection_mode.bind(SelectionMode.FACE))
	selection_edge.toggled.connect(self._update_selection_mode.bind(SelectionMode.EDGE))
	selection_vertex.toggled.connect(self._update_selection_mode.bind(SelectionMode.VERTEX))

	face_set_shape_1.button_up.connect(self._set_face_surface.bind(0))
	face_set_shape_2.button_up.connect(self._set_face_surface.bind(1))
	face_set_shape_3.button_up.connect(self._set_face_surface.bind(2))
	face_set_shape_4.button_up.connect(self._set_face_surface.bind(3))
	face_set_shape_5.button_up.connect(self._set_face_surface.bind(4))
	face_set_shape_6.button_up.connect(self._set_face_surface.bind(5))
	face_set_shape_7.button_up.connect(self._set_face_surface.bind(6))
	face_set_shape_8.button_up.connect(self._set_face_surface.bind(7))
	face_set_shape_9.button_up.connect(self._set_face_surface.bind(8))

	mesh_generators.get_popup().id_pressed.connect(self._on_generators_id_pressed)

func _process(_delta):
	_update_tool_visibility()

func _update_transform_toggle(selected):
	self.transform_mode_changed.emit(selected)

func _update_selection_mode(selected, mode):
	if selected:
		self.selection_mode_changed.emit(mode)

func _update_tool_visibility():
	mesh_tools.visible = selection_mesh.pressed
	face_tools.visible = selection_face.pressed
	edge_tools.visible = selection_edge.pressed
	vertex_tools.visible = selection_vertex.pressed

func set_selection_mode(mode):
	match mode:
		SelectionMode.MESH:
			selection_mesh.pressed = true
		SelectionMode.FACE:
			selection_face.pressed = true
		SelectionMode.EDGE:
			selection_edge.pressed = true
		SelectionMode.VERTEX:
			selection_vertex.pressed = true

func _on_generators_id_pressed(idx):
	match mesh_generators.get_popup().get_item_text(idx):
		"Plane":
			self.generate_plane.emit()
		"Cube":
			self.generate_cube.emit()

func _set_face_surface(idx):
	self.set_face_surface.emit(idx)
