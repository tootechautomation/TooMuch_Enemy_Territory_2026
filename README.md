FRONTLINE: OBJECTIVE v8.94.0
HUD OVERLAP + STRUCTURAL COLLISION + FIRST-PERSON ARMS

FIX 1 — OBJECTIVE HUD OVERLAP
The v8.93 match-flow panel was occupying the same upper-left region as the
existing team/class HUD.

v8.94:
- moves the objective/match-flow panel beneath the team/class panel
- slightly reduces its width/font footprint
- uses viewport-height-aware vertical placement
- event banner now follows the actual panel height
- preserves the existing top-center match HUD and compass

FIX 2 — REMAINING PASS-THROUGH WALLS
Added StructuralCollisionGuard.

At runtime it audits high-confidence structural MeshInstance3D nodes named as:
- walls
- brick walls
- stone walls
- concrete walls
- perimeter/retaining walls
- fences/barriers
- bunker walls

If one has no existing CollisionObject3D, the game adds a world-space static
BoxShape collision guard based on the mesh bounds.

SAFETY:
- does not auto-collide generic whole-building meshes
- skips doors/windows/openings/gaps/gates/arches
- skips player/weapon/pickup/casualty/viewmodel descendants
- skips giant whole-map meshes
- existing colliders remain authoritative and are not duplicated

This specifically targets the recurring brick/gray wall walk-through problem
without sealing intended doors/windows.

FIX 3 — FIRST-PERSON HANDS / ARMS
Added a local-only procedural fallback arm rig.

If no proper imported first-person arm rig exists, v8.94 now builds:
- right forearm/sleeve
- left support forearm/sleeve
- cuffs
- shaped hands
- four finger segments per hand
- thumbs
- team-dependent sleeve colors
- separate primary/pistol hand poses

The fallback attaches to WeaponView so it follows existing recoil, sprint,
reload and Mouse2 weapon-lowering behavior.

IMPORTANT:
This does NOT replace a future high-detail skeletal arm asset. It fixes the
current "floating weapon / no hands" condition now and gives us a stable
first-person presentation layer to upgrade later.

NEXT-PHASE FOUNDATION
v8.94 keeps the objective-awareness HUD from v8.93 and makes it usable without
overlap. With collision and arms stabilized, the next gameplay phases can
return to spawn/reinforcement flow, class abilities and deeper objective play.

PRESERVED
- v8.92 remote-player LOD
- v8.91 memory scaling
- v8.90 CPU/frame pacing
- v8.89 GPU quality tiers
- F8 Low/Balanced/High
- active-weapon-only death drops
- same-weapon ammo scavenging
- cross-faction weapon swaps
- contextual pickup prompts
- resupply stations
- casualty persistence
- shell-casing feedback
- working Axis P38 orientation
- Mouse2 shoulder zoom + persistent crosshair
- server authority/network protocol

Build: 8.94.0
Network protocol: 341
