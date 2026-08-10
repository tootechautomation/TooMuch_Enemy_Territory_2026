FRONTLINE: OBJECTIVE v10.2.0
RUINED CITY GAMEPLAY PASS + URBAN OBJECTIVE FLOW

APPLY OVER
Your working v10.1.1 project.

BLACK RIVER
Operation Black River gameplay is intentionally unchanged in this phase.

RUINED CITY SECTOR VISUALS
Map 2 now creates actual world-space capture zones for:
- West Ruins
- Central Square
- Pillbox Ridge

Each sector has:
- a low-cost capture ring
- a world label
- a small non-shadowing status light

The existing sector-state system now has real Map 2 marker nodes to update.

MAP-AWARE SECTOR HUD
Sector status no longer always reports Village / Rail Yard / Fort.

Ruined City now reports:
W = West Ruins
C = Central Square
P = Pillbox Ridge

Example:
W:A C:X P:D

FORWARD SPAWN FLOW
Ruined City's sector forward spawns are now stage-aware.

Stage 1 — Central Crossing:
Attackers can advance from:
- Central Square
- West Ruins

Defenders can reinforce from:
- Central Square
- Pillbox Ridge

Stage 2 — Eastern Pillbox:
The full three-sector forward-spawn chain becomes active.

Each sector now also has an authored spawn offset instead of placing players
directly at the exact sector center.

URBAN CAPTURE PACING
Ruined City uses faster urban sector capture:
- West Ruins: about 10 seconds at 1-player advantage
- Central Square: about 12.5 seconds
- Pillbox Ridge: about 10 seconds

The slower Central Square is intentional because it controls the main route.

CITY DOMINATION
Existing sector ticket rewards remain.

On Ruined City only:
Owning all 3 sectors additionally drains 1 enemy ticket per sector-ticket
interval.

This makes full territorial control matter without replacing the main
crossing/pillbox objectives.

ROUND LANGUAGE
Ruined City round-start announcement now says:
ROUND START · Open the crossing and seize the city

Black River retains its original round announcement.

UNCHANGED
- Black River geometry/detail/gameplay
- Ruined City geometry/setpieces
- server-authoritative map loading
- map-aware scoreboard/tactical map
- Jeep
- Sherman
- Spitfire
- Bf 109
- WWII character visuals
- Allied Mk 2 grenade
- Axis grenade
- weapon textures/models
- collision/destruction
- contextual E system
- TAB priority scoreboard
- --bots 0 / --bots=0 / --no-bots

Build: 10.2.0
Protocol: 345
