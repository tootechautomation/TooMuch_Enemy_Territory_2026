FRONTLINE: OBJECTIVE v9.06.0
AIRCRAFT ENTRY / VEHICLE STATE STABILITY

CRASH FIXED
client_set_vehicle_state() now receives all 3 required arguments:
- vehicle_id
- position
- seat_id

The stale two-argument call in vehicle_state_changed() was causing the
plane/tank entry crash shown in the screenshot.

AIRCRAFT CONTROL STABILITY
- pitch and steering input smoothing added
- one-frame Space/Crouch input spikes are damped
- safer pitch/roll limits
- minimum ground-clearance safeguard
- smoothed controls reset on exit/respawn

INPUT ISOLATION
- Space/Crouch affect pitch only in aircraft
- Jeep/tank ignore jump/crouch vehicle pitch

PRESERVED
- v9.05 mouse gunner aiming
- Engineer repair
- vehicle tactical markers
- ammo/reload HUD
- multi-seat Jeep/tank
- independent turret
- vehicle respawn/combat/destruction
- real vehicle GLBs
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.06.0
Protocol: 341
