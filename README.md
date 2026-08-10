FRONTLINE: OBJECTIVE — v16.0.0
COMBINED ARMS / ARMORED FRONTLINE OPERATIONS
Network Protocol: 358

SOURCE / COMPATIBILITY
- Built directly on the approved v15.0.0 Squad Command / Tactical Orders overlay.
- Environment freeze preserved. No map geometry, authored spawn coordinates, vehicle assets,
  weapon assets, aircraft assets, ruins, buildings, or collision architecture were redesigned.
- v12.1 safe initial human deployment behavior remains unchanged.
- Existing v13 Frontline Director, v14 Class Warfare, and v15 Tactical Orders remain active.
- --bots 0, --bots=0, and --no-bots behavior remains intact.

MAJOR GAMEPLAY CHANGES

1. ANTI-ARMOR TACTICAL DESIGNATION
- A squad/tactical ping placed close to an enemy vehicle now becomes an ANTI-ARMOR order.
- Enemy vehicles can be designated for 12 seconds.
- Designated vehicles receive a distinct team-visible tactical marker and increased marker range.
- The designation is synchronized reliably to multiplayer clients.
- Late joiners receive any designation that is still active.
- The player who designates the target receives a small spotting/coordination XP reward.
- If the designated vehicle is destroyed before designation expires, the designator receives
  an additional coordination XP reward.
- No new persistent scene nodes are created by this system.

2. ARMORED FRONTLINE SUPPORT
- Occupied vehicles operating near contested or enemy/neutral battlefield sectors now count as
  active armored frontline support.
- Driver and gunner can receive a small periodic objective-support XP reward while actually
  supporting an active front.
- Rewards are throttled to prevent passive XP spam.
- Vehicles do NOT capture sectors by themselves and do NOT alter initial player spawns.

3. FORWARD VEHICLE LOGISTICS
- A team-controlled Supply Depot now doubles as a forward vehicle service point.
- Friendly vehicles that stop near their controlled depot can slowly repair and rearm.
- Forward service is intentionally slower than the existing base service zones.
- Vehicle HUD service text distinguishes BASE SERVICE from FORWARD SERVICE.
- Vehicles must remain below 6 km/h to receive service, preventing drive-through healing.

4. ENGINEER VEHICLE SUPPORT XP
- Engineers now receive XP for successfully repairing damaged vehicles.
- Reward scales modestly with actual repaired health and is capped per repair action.
- Existing repair mechanics and interaction ranges are retained.

5. NETWORK / CLEANUP
- Anti-vehicle designations are server-authoritative.
- Reliable RPC replication keeps tactical target presentation consistent.
- Active designations are restored for late joiners.
- Expired/destroyed designations clean up automatically.
- Round resets clear designation and armored-support reward state.

PRESERVED SYSTEMS
- Black River and Ruined City environment presentation.
- Existing buildings, ruins, tanks, jeeps, aircraft and imported WWII assets.
- Vehicle health/destruction, combat, cameras, service zones and network snapshots.
- Objectives, bridge/crossing, dynamite, command post, sectors and supply depot capture.
- Class Warfare deployables, Medic/Engineer/Field Ops/Soldier/Scout behaviors.
- Squad Command tactical orders and Frontline Director behavior.
- Human base deployment priority, spawn validation and unstuck/recovery systems.
- Combat FX, HUD, scoreboard layering, weapons, grenades, dropped equipment and XP/rank.

RECOMMENDED TEST PASS
1. Confirm normal human initial deployment still uses safe base spawns on both teams/maps.
2. Ping directly beside an enemy tank/jeep and verify ANTI-ARMOR appears.
3. Verify only the designating team sees the target as DESIGNATED and the marker expires.
4. Join a running match while a vehicle designation is active and verify it appears.
5. Destroy a designated enemy vehicle and verify the designator receives coordination XP.
6. Drive/crew a vehicle near a contested/enemy sector and verify modest objective support XP.
7. Capture the Supply Depot, stop a friendly damaged/low-ammo vehicle beside it, and verify
   FORWARD SERVICE repairs/rearms it more slowly than the base service area.
8. Verify an enemy vehicle receives no service from your team-controlled depot.
9. Engineer-repair a damaged friendly vehicle and verify repair XP and feedback.
10. Regression-test v14 deployables and v15 tactical orders after vehicle gameplay.
11. Test --bots 0, --bots=0 and --no-bots on the headless server.

VALIDATION NOTES
- Overlay architecture retained; no missing base-project files were fabricated.
- Static GDScript structural checks performed on modified main.gd and player.gd.
- Unmodified supplied environment/model assets are preserved from v15.
- ZIP CRC/integrity check performed before release.
