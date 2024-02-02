# Plugin to PBR paint a selected MeshInstance through the use of a custom PBR shader
# Main script that creates and destroys the plugin

@tool
extends EditorPlugin

var control: Control
var menu_button: MenuButton
var replace_check_box: CheckBox


# Create whole plugin
func _enter_tree() -> void:
	# Add button to 3D scene UI
	# Shows panel when toggled
	control = preload('res://addons/csg_to_mesh_instance/menu_button.tscn').instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, control)
	menu_button = control.get_node(^'PluginButton')
	replace_check_box = control.get_node(^'ReplaceCheckBox')
	control.hide()

	# Spy on event when object selected in tree changes
	get_editor_interface().get_selection().selection_changed.connect(self.selection_changed)


# Destroy whole plugin
func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, control)

	if control:
		control.free()


func selection_changed() -> void:
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	var can_convert = selection.size() == 1 and selection[0] is CSGShape3D # and selection[0].is_root_shape()

	# If selected object in tree is csg
	if can_convert:
		var root = get_tree().get_edited_scene_root()
		control.show()
		menu_button.root = root
		menu_button.csg = selection[0]
	else:
		control.hide()
