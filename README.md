Frontline: Objective v20.0.0 — ETPRO COMPETITIVE MOVEMENT CORE
Network Protocol 362

SOURCE-OF-TRUTH
Built directly on approved v19.0.0 ET Gameplay Core overlay.
Movement behavior was translated from the uploaded Enemy Territory GPL bg_pmove.c
and informed by the uploaded ETPro 3.2.6 competitive package.

MOVEMENT CORE
- Replaced v19 move_toward planar movement with ET/Q2-style projected acceleration.
- ET-inspired ground friction ratio: 6.
- ET-inspired ground acceleration ratio: 10.
- ET-inspired air acceleration ratio: 1.
- ET-inspired stop-speed ratio translated to Frontline map scale.
- 125 Hz (8 ms) movement velocity integration target with bounded substeps.
- CharacterBody3D collision movement remains one move_and_slide per Godot physics tick
  for collision stability.
- Increased Frontline base movement calibration to 9.15 m/s.
- Sprint 10.85 m/s, crouch 4.95 m/s, jump 6.15 m/s.
- Horizontal velocity is preserved through jump takeoff.
- Air acceleration uses velocity projection rather than steering to a hard air-speed cap.
- Intentional strafe/trick-jump acceleration is therefore possible.
- Short jump buffer/coyote allowance retained for uneven modern 3D geometry.
- Jump retrigger guard prevents accidental same-frame jump spam.

COLLISION / FLOW
- Existing capsule wall anti-tunneling sweep remains.
- Wall response no longer scales away the entire horizontal velocity vector.
- When a wall is detected, only the velocity component pushing into the wall is removed.
- Tangential velocity is preserved to approximate ET PM_ClipVelocity / step-slide flow.
- No giant blockers, environment replacement, or collision-box scenery was added.

ZOOM / COMBAT
- Faster Mouse2 zoom response.
- General zoom FOV 60; Scout optical zoom 26.
- Existing crosshair and lowered-weapon presentation preserved.
- Competitive headshot classification now follows the player's actual Head node,
  including crouched head height, instead of using a broad fixed upper-body cutoff.

ET-STYLE CLASS CHARGE
- Class charge remains persistent through normal respawn (sticky-charge behavior).
- Soldier Heavy Fire costs 75 charge.
- Medic Revive Pulse costs 45 charge.
- Engineer Fortify costs 55 charge.
- Field Ops Artillery costs 100 charge.
- Scout Sensor costs 70 charge.
- Charge regenerates continuously.
- Owning the Command Post increases recharge rate by 15%.
- HUD reports CHARGE percentage / READY state rather than only a cooldown timer.
- Existing class abilities themselves are preserved.

PRESERVATION / REGRESSION RULES
- No map geometry edits.
- No Black River/Ruined City rebuild.
- No spawn coordinate or human initial-deployment edits.
- No vehicle, aircraft, weapon, grenade, model, texture, or environment asset removal.
- v12.1 safe deployment path preserved.
- v13-v19 gameplay layers preserved.
- --bots 0, --bots=0, and --no-bots handling preserved.

RECOMMENDED TEST
1. Use a mouse if possible for the feel test.
2. Run forward, alternate A/D rapidly, then compare direction-change response to v19.
3. Jump while moving and verify horizontal momentum survives takeoff/landing.
4. Try forward+strafe jump turns and see whether skilled movement can build modest speed.
5. Brush along walls/ruins diagonally and verify you slide rather than stop dead.
6. Verify you still cannot pass through real collision geometry.
7. Test Mouse2 zoom and Scout zoom.
8. Test standing/crouched headshots.
9. Spend class charge, die/respawn, verify remaining charge persists and recharges.
10. Capture Command Post and verify class ability becomes ready faster.
11. Regression-test safe initial human spawn, objectives, vehicles, bots, v14-v19 systems.

VALIDATION LIMITATION
The supplied overlay is not a full standalone Godot project, so an engine-level project
launch/parser test cannot be performed from the overlay alone. Static GDScript structure,
version/protocol, package integrity, and unchanged-file hash checks were performed.
