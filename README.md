FRONTLINE: OBJECTIVE v9.07.0
AIRCRAFT HANDLING + VEHICLE FEEDBACK POLISH

AIRCRAFT THROTTLE
W/S now adjusts a persistent aircraft throttle setting instead of acting like
a spring-loaded forward/back input.

Aircraft HUD shows:
THR XX% · GROUND/AIRBORNE

TAKEOFF / LANDING
- aircraft can settle near zero speed on runway at low throttle
- simple lift model added
- nose-up pitch at sufficient speed assists takeoff
- landing gear mode damps vertical impact near ground
- low-speed landing automatically levels pitch
- ground steering is gentler than airborne turning
- existing input smoothing retained

VEHICLE DAMAGE FEEDBACK
Damaged vehicles begin emitting lightweight smoke at ~45% damage.
Smoke automatically clears when vehicle is repaired/respawned/destroyed.

VEHICLE WEAPON FEEDBACK
Tank, Jeep MG and aircraft guns now produce a lightweight muzzle flash at the
server-authoritative weapon origin.

PERFORMANCE
LOW:
- very small particle counts
- no extra shadow lights
BALANCED/HIGH:
- progressively richer smoke/effects

No wheel rigid bodies, shell rigid bodies, or full aerodynamic simulation were
added.

OBJECTIVE INTEGRATION FOUNDATION
Added allied_vehicle_objective_support_bonus() for upcoming objective stages.
It reports a capped bonus when occupied Allied vehicles are positioned near a
target objective. This is intentionally exposed as a helper rather than
silently rewriting established objective balance in this phase.

PRESERVED
- v9.06 vehicle-state crash fix
- aircraft entry stability
- v9.05 mouse turret aiming
- Engineer repair
- tactical vehicle markers
- ammo/reload HUD
- multi-seat Jeep/tank
- independent turret
- vehicle respawn/combat/destruction
- real GLB models
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.07.0
Protocol: 341
