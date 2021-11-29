@tool
extends MeshInstance3D

signal transform_updated

var default_material = preload("../debug_material.tres")

var PlyMesh = preload("../resources/ply_mesh.gd")
@export var ply_mesh: Resource = PlyMesh.new()
@export var materials: Array

func _ready():
	update_materials()

func update_materials():
	if self.mesh:
		for i in range(self.mesh.get_surface_count()):
			if materials != null and materials.size() > i and materials[i]:
				set("material/%s" % [i], materials[i])
			else:
				set("material/%s" % [i], default_material)

var mesh_instance = null
func _enter_tree():
	set_notify_transform(true)
	if not ply_mesh.mesh_updated.is_connected(self._on_mesh_updated):
		ply_mesh.mesh_updated.connect(self._on_mesh_updated)

func _exit_tree():
	set_notify_transform(false)
	if ply_mesh.mesh_updated.is_connected(self._on_mesh_updated):
		ply_mesh.mesh_updated.disconnect(self._on_mesh_updated)

func _notification(what):
	if what == Node3D.NOTIFICATION_TRANSFORM_CHANGED:
		emit_signal("transform_updated")

func _on_mesh_updated():
	if ply_mesh is PlyMesh:
		self.mesh = ply_mesh.get_mesh(self.mesh)
		update_materials()
	else:
		print("not a PlyMesh: %s" % [ply_mesh])

	var collision_shape = get_node_or_null("StaticBody/CollisionShape")
	if collision_shape:
		collision_shape.shape = self.mesh.create_trimesh_shape()
