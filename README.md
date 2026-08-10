FRONTLINE: OBJECTIVE v9.11.0
VEHICLE CAMERA + DRIVING/FLIGHT POLISH + WRECK STABILITY

NEW VEHICLE CAMERA MODES
While seated, press V:

CHASE
- normal third-person vehicle view
- balanced distance for driving/flying

CLOSE
- tighter view for aiming and confined streets

TACTICAL
- higher/farther camera for route awareness and tank positioning

Vehicle HUD now shows:
CAM CHASE / CLOSE / TACTICAL
and the V CAMERA control hint.

CAMERA FEEL
Vehicle camera follow now scales modestly with vehicle speed.
Fast aircraft/Jeeps follow more firmly.
Tactical camera is intentionally smoother.

Vehicle FOV is now separate from infantry ADS FOV:
- Jeep/tank/aircraft receive vehicle-specific FOV targets
- faster motion adds a small FOV expansion
- no motion blur or expensive postprocessing is required
- infantry ADS code no longer fights the vehicle camera every frame

WRECK STABILITY FIX
Destroyed vehicle snapshots could repeatedly call set_destroyed_visual().
Previously that method multiplied visual scale by 0.98 every call, which could
gradually shrink a wreck over repeated network snapshots.

v9.11 wreck visuals are idempotent:
- wreck tilt/scale is applied once
- repeated destroyed snapshots do not compound transforms
- respawn resets the wreck state cleanly

PRESERVED
- v9.10.2 parser fix
- v9.10.1 finite-transform/NaN recovery
- destructible streets/cover
- tank bunker support
- anti-vehicle grenades
- vehicle service areas
- aircraft takeoff/landing
- multi-seat Jeep/tank
- turret/mouse aiming
- vehicle combat/HUD/respawn
- real Willys/Sherman/Spitfire/Bf109 GLBs
- F6/F8 quality controls
- --bots 0 / --bots=0 / --no-bots

Build: 9.11.0
Protocol: 341
