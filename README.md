FRONTLINE: OBJECTIVE v10.6.0
MAJOR UPGRADE — TRUE INVISIBLE ARCHITECTURE COLLISION

WHAT CHANGED

1. REMOVED THE LARGE TEMPORARY GRAY-BOX COVER PASS
The v10.3/v10.5 Ruined City gray-box street/building cover geometry has been
removed. The real imported buildings/ruins remain the visual architecture.

2. TRUE COLLISION FROM THE ACTUAL IMPORTED MESHES
v10.6 no longer creates world-AABB box proxies for imported buildings.

Instead, on BOTH dedicated servers and clients:
- each substantial MeshInstance3D is inspected
- Mesh.create_trimesh_shape() creates an invisible ConcavePolygonShape3D
- a StaticBody3D is created
- its global transform is set to the exact imported MeshInstance3D transform
- collision layer/mask are explicitly 1
- the temporary source scene is removed

This means collision follows actual walls/ruins instead of giant rectangular
blockers.

3. LARGE BACKDROP/TERRAIN MESHES ARE SKIPPED
Tiny decorative meshes and extremely large combined/background meshes are not
turned into collision. This avoids turning the entire city backdrop into one
enormous physics surface.

4. OUTER MAP BOUNDARIES ARE NOW INVISIBLE
The four perimeter safety walls retain collision but no longer render gray
box meshes.

SERVER LOGS
On Ruined City startup, look for:
Ruined City true mesh collision: RCMesh_WestRuins -> X shapes
Ruined City true mesh collision: RCMesh_City -> X shapes
Ruined City true mesh collision: RCMesh_Pillbox -> X shapes
Ruined City authoritative TRUE architecture collision: X shapes

TEST
Walk directly into:
- house exterior walls
- ruined masonry walls
- the pillbox
- large structural ruins

Then test door/window/opening areas. Because this now follows actual mesh
triangles, usable openings should behave much better than box proxies.

PRESERVED
- Operation Black River
- Ruined City objectives/sectors
- Jeeps/tanks/planes
- WWII soldiers
- Allied Mk 2 / Axis grenades
- weapon textures/models
- bot routes
- map-aware HUD/scoreboard
- contextual E
- F6/F8
- --bots 0

Build: 10.6.0
Protocol: 350
