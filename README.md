FRONTLINE: OBJECTIVE v9.12.0
VEHICLE CAMERA COLLISION + SAFE EXIT SYSTEM

CAMERA COLLISION
CHASE / CLOSE / TACTICAL vehicle cameras now run one inexpensive raycast from
the vehicle toward the requested camera position.

If a building, wall, destructible barrier, or other world collision blocks the
camera:
- camera is pulled in front of the blocking surface
- a small surface offset prevents near-plane clipping
- camera cannot collapse completely into the vehicle
- HUD briefly shows CAM BLOCKED while obstruction is active

This eliminates the common third-person problem where the camera sits on the
other side of a wall while the vehicle remains inside a street/alley.

PERFORMANCE
Only one raycast is used per local vehicle camera update.
There is no SpringArm3D physics tree and no additional network traffic.

SAFE VEHICLE EXIT
Vehicles now provide multiple exit candidates:
1. right side
2. left side
3. rear
4. front
5. elevated emergency exit

The server evaluates candidates using a player-sized capsule shape query.
Blocked candidates are skipped.

The selected exit is then raycast onto nearby ground.

This reduces:
- exiting inside brick walls
- exiting inside sandbags
- exiting inside another vehicle
- falling through geometry after exit
- getting trapped beside tanks in narrow streets

DESTROYED VEHICLE EJECTION
Driver and gunner ejection now use the same safe-exit selection logic.

FALLBACK
If every candidate is obstructed, the player is placed above the vehicle so
normal player physics can settle them rather than inserting them into geometry.

PRESERVED
- v9.11 CHASE/CLOSE/TACTICAL camera modes
- wreck idempotency
- v9.10 finite-transform recovery
- destructible streets and cover
- vehicle objective combat
- vehicle service areas
- aircraft handling
- multi-seat/turret system
- real vehicle GLBs
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.12.0
Protocol: 341
