FRONTLINE: OBJECTIVE v9.09.0
VEHICLE OBJECTIVE COMBAT + ANTI-VEHICLE EXPLOSIVES + DESTRUCTIBLE BARRIERS

TANKS NOW SUPPORT THE BUNKER ASSAULT
During Stage 2, direct Allied tank-cannon hits on the bunker objective inflict:
12 bunker integrity damage per shell.

Dynamite remains the primary objective mechanic. The tank is support rather
than an automatic replacement for Engineers.

ANTI-VEHICLE GRENADES
Normal grenade explosions now apply reduced radial damage to enemy vehicles.

- friendly vehicles are ignored
- vehicle blast radius is slightly larger than infantry radius
- damage falls off with distance
- grenades threaten Jeeps/aircraft and slowly wear down tanks
- destroyed vehicles use the existing explosion/ejection/respawn system

DESTRUCTIBLE BATTLEFIELD BARRIERS
Four lightweight destructible barriers have been added around the central
vehicle approaches.

They:
- use simple StaticBody3D box collision
- cost almost nothing while intact
- can be destroyed by tank/vehicle weapons
- can be destroyed by grenades
- disappear rather than becoming dozens of rigid-body fragments
- reset every round

This is the performance-friendly foundation for later:
- destructible brick walls
- sandbag positions
- wooden barricades
- damaged building sections
- vehicle roadblocks

PERFORMANCE
No rigid-body debris simulation was added.
Destruction is replicated as a single state change plus a quality-scaled
explosion effect.

PRESERVED
- v9.08 vehicle service zones and bridge support
- v9.07 aircraft takeoff/landing/throttle
- v9.06 vehicle-state stability
- mouse turret aiming
- Engineer vehicle repair
- vehicle tactical markers
- multi-seat vehicles
- vehicle respawn/combat
- real Willys/Sherman/Spitfire/Bf109 GLBs
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.09.0
Protocol: 341
