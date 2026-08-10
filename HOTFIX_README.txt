FRONTLINE: OBJECTIVE v8.42 - CESIUMMAN IMPORT HOTFIX

This fixes the Godot error:
Resource file not found: res://assets/models/cc_by/cesium_man/CesiumMan_0.jpg

INSTALL:
1. Close Godot.
2. Extract this ZIP directly into the root of your Frontline Objective v8.42 project.
3. Allow Windows to merge the assets folder.
4. Delete the project's .godot folder if it exists. This is only Godot's import cache.
5. Re-open project.godot and allow Godot to finish importing assets.
6. Run the project.

The JPG in this patch was extracted directly from the CesiumMan.glb already included
with the project, so it matches the model's embedded texture exactly.
