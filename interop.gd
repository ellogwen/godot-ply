static func get_instance(p, node_file_path):
	var base_control = p.get_editor_interface().get_base_control()
	var existing = base_control.get_node_or_null("plugin_interop")
	if existing:
		print("Interop already installed")
		return existing
	var n = load(node_file_path).new()
	n.name = "plugin_interop"
	base_control.add_child(n)
	return n
