FRONTLINE: OBJECTIVE v10.0.0
MULTI-MAP FOUNDATION + MAP 2: RUINED CITY PROTOTYPE

IMPORTANT
Operation Black River is still the DEFAULT and its world-building/visual stack
is preserved exactly.

NORMAL LAUNCH:
No new map flag is needed.
The game loads Operation Black River.

MAP 2:
Use:
--map ruined_city

Aliases:
--map=ruined_city
--map city
--map map2

For multiplayer Map 2 testing, launch BOTH the server and test client with the
same --map ruined_city option in this prototype phase.

MAP 1 aliases:
--map black_river
--map=black_river
--map map1

WHAT v10 ADDS
A real map-selection layer now exists before world construction.

Map 1:
Operation Black River
- existing detailed map untouched
- existing visual passes untouched
- existing vehicle staging untouched
- existing destructible barriers untouched

Map 2:
Ruined City
- separate map builder script
- separate spawn positions
- separate forward-spawn positions
- separate sector positions
- separate vehicle/aircraft staging
- independent visual environment
- independent collision layout
- the previously supplied environment GLBs are used ONLY here

MAP 2 ASSETS
assets/maps/ruined_city/city_ruins_environment.glb
assets/maps/ruined_city/ww2_low_poly_city_scene.glb
assets/maps/ruined_city/mothecombe_pillbox.glb

PERFORMANCE / COLLISION DESIGN
The large imported city assets are visual setpieces.
They do NOT generate automatic trimesh collisions.

Map 2 gameplay collision is built with simple authored StaticBody3D boxes.
This keeps:
- laptop performance reasonable
- server collision deterministic
- players from falling through imported decorative meshes
- us from recreating the invisible/misaligned wall problems seen earlier

MAP 2 LAYOUT
Approximate playable footprint: 132m x 92m.

Three major routes:
- northern ruined street
- central square
- southern alley

Objectives currently reuse the proven two-stage game rules:
1. Engineers establish the central crossing.
2. Attackers advance to the eastern pillbox and arm dynamite.

This deliberately reuses the stable objective code while Map 2's unique
mission mechanics are developed later.

VEHICLES ON MAP 2
Both teams receive:
- Jeep
- tank
- aircraft

They use new Map 2 staging positions.
Operation Black River's vehicle positions are unchanged.

CURRENT PROTOTYPE LIMITATION
Map selection is launch-time in v10.0.0. The server does not yet force a
connected client's map selection. For Map 2 multiplayer testing, use the same
--map option on server and client.

SAFE OVERLAY INSTALL
Apply this over the working v9.27.7 project.
Do not delete existing assets.

PRESERVED FROM v9.27.7
- restored detailed Operation Black River
- Willys Jeep
- M4 Sherman
- Spitfire
- Bf 109
- WWII Allied/German soldiers
- Allied Mk 2 grenade
- Axis grenade behavior
- weapon handling/textures
- spatial audio
- bot AI
- TAB priority scoreboard
- contextual E interactions
- spawn recovery
- --bots 0 / --bots=0 / --no-bots

Build: 10.0.0
Protocol: 342
