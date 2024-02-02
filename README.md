# CSG To MeshInstance
This is a heavily-modified fork of StrayEddy's
[original plugin.](https://github.com/StrayEddy/GodotPlugin-CSGToMeshInstance)
that allows one to take any `CSGShape3D`-derived node
(e.g. `CSGBox3D`, `CSGPolygon3D`) and generate a `MeshInstance3D` or
`CSGMesh3D` node based on it without it having to be the root shape (although
it still works when used on root shapes).

## How to use:
- Open or create a new scene.
- Create a structure with some CSG shapes.
- Select any one of the shapes (parent OR child) and observe that you now have
a button in the spatial editor toolbar that reads "CSG Stuff" and beside it,
a checkbox that reads "replace".
    - If this is checked, this will replace the currently-selected `CSGShape3D`
    node with the newly-created `CSGShape3D` or `MeshInstance3D` instead of
    adding it as a sibling.
- Click "To CSGShape3D" or "To MeshInstance3D" depending on your preference.
- There should now be a new node whose mesh is that of the CSG shape.
