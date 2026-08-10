FRONTLINE: OBJECTIVE v10.5.0
MAJOR FIX — AUTHORITATIVE ARCHITECTURE COLLISION

ROOT CAUSE
The previous GLB collision pass ran inside the visual-instantiation function.
That function exits on a dedicated/headless server.

Because multiplayer movement is server-authoritative, the server therefore had
NO collision for the imported ruins/buildings. The gray authored StaticBody3D
walls worked because they were created on the server.

FIX
Ruined City now builds imported-architecture collision independently of
rendering on BOTH dedicated servers and clients.

For each imported environment GLB, v10.5:
- loads the scene temporarily
- applies the same scale, rotation, and position as the visible model
- transforms substantial mesh bounds into WORLD SPACE
- creates explicit StaticBody3D + BoxShape3D proxies on collision layer 1
- removes the temporary source scene
- then separately loads normal visual scenery on graphical clients

This uses conservative box proxies rather than trimesh collision for better:
- dedicated-server reliability
- laptop performance
- CharacterBody3D movement
- vehicle movement
- predictable collision
- fewer tiny mesh snags

FILTERED OUT
Ground, terrain, roads, floors, glass/windows, foliage, fire/smoke, wires,
signs, lights, and tiny clutter do not receive proxy collision.

SERVER DIAGNOSTICS
When Ruined City starts, the server should now print:
Ruined City proxy collision: RCProxy_WestRuins -> X blockers
Ruined City proxy collision: RCProxy_City -> X blockers
Ruined City proxy collision: RCProxy_Pillbox -> X blockers
Ruined City authoritative architecture collision: X proxies

TEST THE SAME BUILDINGS FROM THE SCREENSHOT
You should no longer be able to simply walk through the imported architecture.
If a specific doorway/opening becomes blocked, that can now be adjusted
precisely because the proxies are deterministic.

UNCHANGED
Operation Black River, objectives, sectors, vehicles/aircraft, WWII soldiers,
weapons/textures, Allied Mk 2 grenade, Axis grenade, bots, TAB, E interactions,
F6/F8, and --bots 0 behavior remain intact.

Build: 10.5.0
Protocol: 349
