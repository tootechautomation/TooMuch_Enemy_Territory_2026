FRONTLINE: OBJECTIVE v15.0.0
MAJOR UPDATE — SQUAD COMMAND / TACTICAL ORDERS / FIRETEAM COORDINATION
Network Protocol 357

SOURCE / COMPATIBILITY
- Built directly on the approved v14.0.0 Class Warfare / Frontline Support overlay.
- v14 class support/deployable systems are preserved.
- No environment redesign, map replacement, procedural rebuilding, or giant visible collision boxes were added.
- Existing v12.1 safe human deployment/spawn recovery logic remains untouched.
- Existing --bots 0, --bots=0 and --no-bots command-line parsing remains present.
- Existing maps, grenades, support deployable script, Ruined City map script, objectives, vehicles, FX and other referenced base-project systems remain in place.

SQUAD COMMAND
- The existing squad-ping action now creates a temporary server-authoritative tactical order at the marked world position.
- Orders are classified automatically from battlefield state as ATTACK, DEFEND, CONTEST or REGROUP.
- Sector classification uses the existing v13 sector-control/frontline data rather than creating a parallel objective system.
- Tactical orders last 14 seconds and clean themselves up server-side.
- Orders are intentionally limited in scope instead of redirecting every bot on the team.

BOT FIRETEAMS
- A human order can assign up to four nearby allied bots.
- Assignment favors bots close to the issuing player and/or the ordered position.
- Assignment radius is limited to 38 meters to keep orders local and believable.
- Assigned bots use the order position as a tactical anchor while the order is active.
- Engineers preserve objective urgency priority and can ignore a tactical order when objective pressure is high.
- Medics still override movement orders for wounded/revive priorities.
- Field Ops can follow tactical orders instead of always drifting back toward generic support clusters.
- Scouts and Soldiers can use ordered positions as squad-level combat anchors.
- Existing vehicle avoidance, suppression cover, squad formations, shared enemy intelligence and class-warfare goals remain active.

FRONTLINE DIRECTOR INTEGRATION
- Orders near enemy-held sectors become ATTACK orders.
- Orders in contested sectors become CONTEST orders.
- Orders in friendly-held sectors become DEFEND orders.
- Tactical orders therefore reinforce the existing Frontline Director instead of replacing it.
- Order markers and team callouts display the tactical intent and distance.

TEAMPLAY / SCORING
- Issuing an order that successfully assigns a local bot fireteam grants a small coordination XP reward.
- Completing ATTACK/CONTEST orders by securing the associated sector awards additional objective XP to the issuer.
- Holding a DEFEND order through its lifetime while retaining the sector awards a smaller defense XP reward.
- Completion produces a tactical-order completion feed event.

MULTIPLAYER / NETWORKING
- Full bot assignment/order state remains server-authoritative.
- Clients receive only compact tactical-order display state through reliable RPCs.
- The latest team tactical order appears in the objective/compass presentation while active.
- Active tactical order display state synchronizes to late-joining clients with its remaining lifetime.
- Order cleanup only clears the matching displayed order so a newer order is not accidentally removed by an older one expiring.
- Network protocol incremented from 356 to 357.

PERFORMANCE
- No persistent particle systems or map geometry were added.
- Tactical orders use small Dictionary state records and existing ping markers.
- Maximum assigned bot count per order is four.
- Orders self-expire quickly and are pruned every server update.
- No hundreds-of-node deployable or marker system was introduced.

TEST FOCUS
1. Start the headless server and verify v15.0.0 / protocol 357 handshake.
2. Confirm --bots 0, --bots=0 and --no-bots still reliably disable bot spawning.
3. Confirm initial human deployment still uses the known-safe base deployment and does not spawn inside architecture.
4. Use the existing squad-ping control on an enemy-held sector; marker/callout should read ATTACK and nearby allied bots should move toward it.
5. Ping a contested sector; it should read CONTEST.
6. Ping a friendly-held sector; it should read DEFEND.
7. Verify only a limited local fireteam responds rather than every bot on the team.
8. Confirm Medic bots still abandon an order when a nearby teammate needs revive/triage.
9. Confirm Engineer bots retain objective priority during high objective urgency and are not pulled away from critical construction/dynamite work.
10. Confirm Soldier / Field Ops / Scout bots can visibly react to an active order when no higher-priority behavior overrides it.
11. Capture a sector after issuing ATTACK/CONTEST and verify the tactical-order completion event / XP occurs.
12. Hold a friendly sector through a DEFEND order and verify the smaller defense reward occurs when the order expires.
13. Join an in-progress match while a tactical order is active; the current order should appear for the late-joining client for the correct remaining duration.
14. Confirm v14 aid stations/ammo crates, Engineer barricades/Fortify, Field Ops artillery, Soldier Heavy Fire, Medic Revive Pulse and Scout Sensor Beacon still work.
15. Confirm TAB scoreboard remains above the normal HUD and existing objective, vehicle, combat FX, environment and collision presentation remain unchanged.

FILES MODIFIED IN THIS OVERLAY
- main.gd
- scripts/player.gd
- V15.0_RELEASE_NOTES.txt (new)

FILES INTENTIONALLY NOT MODIFIED
- scripts/class_warfare_deployable.gd
- scripts/grenade.gd
- scripts/maps/ruined_city_map.gd
- V13.0_README.txt
- V14.0_RELEASE_NOTES.txt
