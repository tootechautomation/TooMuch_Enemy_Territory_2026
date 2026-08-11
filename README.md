Frontline: Objective v21.0.0 — ET CLASS RHYTHM / TRACKING COMBAT
Network Protocol 363

SOURCE OF TRUTH
Built directly on the approved v20 ETPro Competitive Movement Core overlay.
v20 movement physics are intentionally preserved rather than retuned.

MEDIC
- Direct revive range increased from 2.8m to 3.35m.
- Interact cadence reduced substantially for faster syringe-like revive response.
- Revived players return at 52% class health (minimum 55 HP).
- Medic ability is now a cheap repeatable medical-support action (28 charge).
- Ability drops a health supply pack and can immediately heal one nearby living teammate.
- Crouch + ability preserves the v14 persistent aid-station deployment.
- Revive remains a deliberate direct teammate interaction rather than a mass revive pulse.

FIELD OPS
- Normal ability use = fast ammo support (30 charge).
- Mouse2 + ability = full-charge aimed artillery (100 charge).
- Normal support toss creates ammunition without forcing artillery cooldown.
- Crouch + normal ability preserves the v14 persistent ammo-crate deployment.

ENGINEER
- Fortify ability cost reduced to 50 charge.
- Bridge/objective construction progresses 2 units per interaction instead of 1.
- Defuse progress advances 2 units per interaction instead of 1.
- Existing dynamite, repair, barricade and frontline-fortification systems are preserved.

SOLDIER / SCOUT
- Existing Heavy Fire and Sensor roles preserved.
- Existing class-charge behavior from v20 remains.

TRACKING COMBAT
- Moving spread reduced to 72% of prior resource values.
- Hip spread reduced to 82% of prior resource values.
- Camera recoil greatly reduced so sustained SMG/rifle tracking during strafing is viable.
- Weapon-model kick remains for readable firing feedback.
- v20 real-head hit classification is preserved.

REINFORCEMENT RHYTHM
- Base reinforcement wave changed from 10s to 14s.
- Command Post/forward wave bonus increased from 2.0s to 2.5s.
- Goal: more recognizable team respawn pushes and less constant player trickle.

CONTROLS / CLASS SUPPORT
- Medic: Ability = quick medical support; Crouch+Ability = persistent aid station.
- Field Ops: Ability = ammo; Mouse2+Ability = artillery; Crouch+Ability = ammo crate.
- Engineer: Interact remains primary objective action.
- Existing M class menu, TAB scoreboard, zoom, grenades, vehicles and objective controls remain.

PRESERVATION
- v20 ETPro movement constants and movement functions preserved.
- No map/environment edits.
- No spawn coordinate/deployment edits.
- No asset removal/replacement.
- No vehicle/objective system removal.
- Existing --bots 0, --bots=0 and --no-bots support preserved.
- v13-v20 layers remain present.

TEST
1. Confirm v20 movement still feels unchanged.
2. Medic: approach a downed teammate and revive using INTERACT.
3. Medic: use repeated health support during a moving firefight.
4. Medic: crouch+ability and verify aid-station deployment still works.
5. Field Ops: normal ability should drop ammo without artillery.
6. Field Ops: Mouse2+ability should call artillery.
7. Field Ops: crouch+normal ability should preserve persistent ammo-crate deployment.
8. Engineer: bridge construction and defuse should feel noticeably quicker.
9. Track strafing enemies with automatic weapons and judge camera kick/spread.
10. Die with teammates and verify the 14s reinforcement cadence produces group pushes.
11. Regression-test objectives, bots, vehicles, safe initial spawning and v13-v20 systems.

VALIDATION LIMITATION
The supplied release is an overlay rather than a complete standalone Godot project.
No Godot executable is installed in the artifact runtime, so full engine parse/launch
validation cannot be performed here. Structural, preservation and ZIP integrity checks
were performed.
