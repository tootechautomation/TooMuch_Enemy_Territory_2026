Frontline: Objective v19.0.0 — ET GAMEPLAY CORE
Network Protocol 361

PURPOSE
This phase deliberately pauses new strategic layers and retunes the moment-to-moment
infantry experience toward the fast, responsive movement/class rhythm that made
Wolfenstein: Enemy Territory compelling.

MAJOR CHANGES
- Faster base infantry movement and lateral response.
- Momentum-based ground acceleration/deceleration instead of instantaneous planar snapping.
- Momentum-preserving jumps with controlled air steering.
- 150 ms jump buffer and 95 ms coyote window for rubble/ledge responsiveness.
- Air speed remains capped to prevent runaway acceleration/map escape behavior.
- Mouse2 shoulder zoom is substantially faster and less movement-restrictive.
- General zoom FOV is less tunnel-like; Scout retains stronger optical magnification.
- Existing persistent crosshair/weapon-lowering presentation remains.
- Class ability timing now presents as an ET-inspired shared recharge/power cycle.
  Existing class abilities are preserved rather than removed.
- Existing v13-v18 strategic/AI systems remain available underneath the core gameplay.

PRESERVATION
- No map/environment geometry edits.
- No spawn coordinate/deployment edits.
- No GLB/model/texture removal or replacement.
- No vehicle/objective/deployable removal.
- v12.1 safe initial human deployment architecture preserved.
- Existing bot-disable CLI paths preserved.

TEST
1. Run/strafe responsiveness and diagonal movement.
2. Repeated jump -> land -> jump cadence.
3. Air steering without excessive acceleration.
4. Low rubble/ledge traversal and normal wall collision.
5. Mouse2 zoom in/out responsiveness and crosshair visibility.
6. Scout zoom.
7. Class ability recharge/activation for all classes.
8. Medic/Field Ops/Engineer/Soldier support behavior.
9. Initial human spawning and bot spawning.
10. Full regression of v13-v18 systems.s
