Frontline: Objective v22.0.0 — ET FIRETEAMS / TEAM COHESION
Network Protocol 364

PURPOSE
Build on the approved v20 movement and v21 class/combat rhythm by making small-team
cooperation feel more like Enemy Territory fireteams without adding another strategic
map layer.

FIRETEAMS
- A human tactical ping now establishes/refreshes a lightweight fireteam around that player.
- Up to 5 nearby allied bots join the human leader (6 members including leader).
- Human teammates are never forcibly reassigned.
- Existing v15 tactical orders preferentially assign the leader's fireteam.
- Order markers report FT member count.
- Between explicit orders, assigned bots regroup toward their human leader when they drift
  beyond the cohesion radius.
- Medic casualty priority still overrides fireteam regrouping.
- Engineer high-urgency objective priority still overrides tactical orders.
- Field Ops, Soldier and Scout retain their existing class logic.

TEAM COHESION
- Mixed-class fireteams operating together can periodically reward the leader with small
  cohesion XP.
- Reward requires at least 3 nearby living members and at least 2 classes.
- Reward is throttled to prevent passive XP farming.
- No persistent world nodes are created for fireteam membership.

HUD
- Existing ET route/status line now displays FIRETEAM LEAD / FIRETEAM membership when active.
- Compass/objective status includes fireteam state.
- Existing tactical order and battlefield-operation presentation remains.

PRESERVATION
- v20 ETPro movement physics unchanged.
- v21 Medic/Field Ops/Engineer/combat/reinforcement tuning unchanged.
- No environment, map geometry, spawn coordinate, vehicle, weapon model, GLB or texture edits.
- Safe initial human deployment preserved.
- Existing --bots 0, --bots=0 and --no-bots behavior preserved.

TEST
1. Spawn with bots and issue a tactical ping.
2. Confirm the ping reports an FT count and only a small nearby group responds.
3. Move away after the order expires and see whether fireteam bots regroup toward you.
4. Ping another objective and confirm the same fireteam preferentially responds.
5. Verify Medic bots still break formation for wounded/downed teammates.
6. Verify Engineers still prioritize urgent construction/dynamite/defuse work.
7. Verify HUD/compass reports fireteam state without covering the scoreboard.
8. Regression-test v20 movement, v21 class support, reinforcement waves, safe spawn,
   objectives, vehicles, deployables and bot-disable CLI options.

VALIDATION LIMITATION
This package remains the source-of-truth overlay, not the full standalone Godot project.
Static structural checks, preservation hashes and ZIP integrity were performed.
