# Button to activate the painting and show the paint panel

@tool
extends MenuButton


enum CSGToMeshInstanceOptions {
	TO_MESH_INSTANCE_3D = 0,
	TO_CSG_MESH_3D = 1,
}


var root: Node
var csg: CSGShape3D

@onready var popup := get_popup()


static func _children_recurse_set_owner(children: Array[Node], owner: Node) -> void:
	for child in children:
		_children_recurse_set_owner(child.get_children(), owner)
		child.owner = owner


static func get_meshes(tree: SceneTree, csg: CSGShape3D) -> Array:
	var old_parent := csg.get_parent()
	var old_owner := csg.owner
	var old_index := csg.get_index()
	var meshes: Array

	if not csg.is_root_shape():
		csg.reparent(EditorInterface.get_edited_scene_root())
		csg.owner = EditorInterface.get_edited_scene_root()
		_children_recurse_set_owner(csg.get_children(), csg.owner)

		print_debug('csg is root shape after reparenting: ' + str(csg.is_root_shape()))

	if not csg.is_root_shape():
		push_error('failed to temporarily reparent node in order to make it a root shape thus making its meshes unavailable.')
		return meshes

	#
	# TODO: probably want to do a timeout here or else you risk locking up
	# your shit
	#
	while not csg.get_meshes():
		print_debug('waiting for frame to process...')
		await tree.process_frame

	meshes = csg.get_meshes()
	print_debug('csg meshes returned: ' + str(meshes))

	if csg.is_root_shape():
		csg.reparent(old_parent)
		csg.owner = old_owner
		_children_recurse_set_owner(csg.get_children(), csg.owner)
		old_parent.move_child(csg, old_index)

	while old_parent is CSGShape3D:
		old_parent._update_shape()
		old_parent = old_parent.get_parent()

	return meshes


func _ready() -> void:
	popup.connect(&'index_pressed', convert_csg)


func convert_csg(opt: CSGToMeshInstanceOptions) -> void:
	var meshes := await get_meshes(get_tree(), csg)

	if not meshes or meshes.is_empty():
		push_error('Could not get meshes.')
		return

	var mesh_3d_node: Node3D

	match opt:
		CSGToMeshInstanceOptions.TO_MESH_INSTANCE_3D:
			mesh_3d_node = MeshInstance3D.new()
		CSGToMeshInstanceOptions.TO_CSG_MESH_3D:
			mesh_3d_node = CSGMesh3D.new()

	var csg_mesh: ArrayMesh = meshes[1]
	var csg_transform := csg.global_transform
	var csg_name := csg.name
	var csg_old_index := csg.get_index()
	var csg_new_index := csg_old_index
	var csg_old_parent := csg.get_parent()
	var should_replace := ($'../ReplaceCheckBox' as CheckBox).button_pressed

	mesh_3d_node.mesh = csg_mesh
	csg_new_index += int(not should_replace)

	if should_replace:
		csg_old_parent.remove_child(csg)

	csg_old_parent.add_child(mesh_3d_node)
	csg_old_parent.move_child(mesh_3d_node, csg_new_index)

	mesh_3d_node.owner = root
	mesh_3d_node.global_transform = csg_transform
	mesh_3d_node.name = csg_name

	if mesh_3d_node.mesh is ArrayMesh:
		mesh_3d_node.mesh.lightmap_unwrap(mesh_3d_node.global_transform, 0.05)

	if mesh_3d_node is MeshInstance3D:
		mesh_3d_node.use_in_baked_light = true
