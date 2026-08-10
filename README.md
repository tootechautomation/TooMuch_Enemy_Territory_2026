FRONTLINE: OBJECTIVE v9.28.0
REAL WWII ASSET INTEGRATION + FIRST MAP EXPANSION

NEW USER-SUPPLIED ASSETS INCLUDED

CHARACTERS
- assets/external/characters/ww2_allied_soldier.glb
- assets/external/characters/ww2_german_wehrmacht_soldier.glb

The external-character system now prefers these models for Allied/Axis remote
players and bots.

IMPORTANT:
Both supplied character GLBs are static/unrigged models (no Skeleton3D or
animations in the GLB metadata). v9.28 therefore permits high-quality unrigged
characters and applies lightweight procedural walk bob/lean/crouch motion.
If rigged replacements are added later, the existing AnimationPlayer path is
still used automatically.

MAP / ENVIRONMENT
- city_ruins_environment.glb
- ww2_low_poly_city_scene.glb
- mothecombe_pillbox.glb
- vairogs_v2.glb

PLACEMENT
- City ruins: west/north-west battle edge
- WWII low-poly city: east/north-east backdrop
- Mothecombe pillbox: north approach / future expansion direction
- Vairogs automobile: depot/street scenery

These are positioned around the outer portions of Operation Black River so the
first map gains a more convincing WWII skyline and recognizable setpieces
without moving the existing bridge/bunker objective chain.

The very large city/pillbox downloads are used primarily as visual setpieces in
this phase. Runtime trimesh collision generation is disabled for them to avoid
a major startup/FPS penalty and to avoid reintroducing wall collision bugs.
We can convert selected pieces into authored/simple collision zones in a later
map-expansion phase.

VAIROGS
Inspection of the supplied GLB shows automobile components including body,
bonnet, bumper and multiple seats. v9.28 uses it as a parked vehicle prop first.
It is intentionally NOT made drivable yet; the existing Willys/Sherman/aircraft
handling remains unchanged. It can become a fourth drivable vehicle after its
scale/origin/seat alignment is tested in-game.

ALLIED GRENADE
- assets/external/weapons/mk2_grenade.glb

Allied thrown grenades now attach the real Mk 2 model. The external asset
adapter automatically scales it to approximately 18 cm overall length.
Axis grenades continue using the existing Model 24 candidate when available,
otherwise the gameplay grenade fallback remains.

EXISTING VEHICLE GLBS PRESERVED
- Willys Jeep
- M4 Sherman
- Spitfire
- Bf 109

PERFORMANCE
- external setpieces use distance LOD metadata
- no generated trimesh collision for the large new scene downloads
- no new physics on backdrop assets
- no new dynamic lighting
- unrigged character procedural motion is transform-only
- headless server does not instantiate visual assets

PRESERVED
- v9.27.2 interaction prompt scope fix
- contextual E interaction
- v9.26 weapon handling
- v9.25 TAB priority scoreboard
- v9.24 bot intelligence
- spawn safety / U unstuck
- spatial audio / effect budgets
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.28.0
Protocol: 341
