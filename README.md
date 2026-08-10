FRONTLINE: OBJECTIVE v14.0.0
MAJOR UPDATE — CLASS WARFARE / FRONTLINE SUPPORT
Network Protocol 356

SOURCE / COMPATIBILITY
- Built directly on the supplied v13.0.0 Battlefield Flow major overlay.
- v13 environment/map scripts and all supplied GLB assets are preserved.
- No map redesign, procedural replacement, or giant visible collision boxes were added.
- v12.1 safe human deployment logic was left intact.
- Existing --bots 0, --bots=0 and --no-bots command-line behavior remains in main.gd.

CLASS WARFARE
MEDIC
- Revive Pulse still heals/revives nearby teammates.
- Revive Pulse now also establishes a temporary team aid station.
- Aid stations are server-authoritative, destructible, time-limited, team restricted, and deliberately used with INTERACT.
- Aid stations near the Frontline Director pressure sector receive a modest frontline durability/healing bonus.
- Support providers receive XP when teammates use their station.

FIELD OPS
- Artillery and the existing immediate ammunition pack remain.
- Artillery Strike now also establishes a temporary team ammunition crate.
- Ammo crates use the same server-authoritative, destructible, capped support-deployable framework.
- Frontline crates receive a modest durability/ammo bonus.

ENGINEER
- Existing manual barricade deployment remains unchanged.
- Fortify now uses frontline-aware repair support and gives additional repair value when the engineer is operating near the current pressure sector.
- Objective construction, dynamite arming/defusing, and existing barricade limits remain intact.
- No automatic collision wall is spawned around engineers or players.

SOLDIER
- Existing Heavy Fire specialization is preserved as the sustained-fire / suppression role.
- Soldier bots can now use the class-warfare tactical goal path to reinforce the active pressure sector.

AI / FRONTLINE DIRECTOR
- Class-warfare goals now participate directly in bot movement before generic route travel.
- Medics retain casualty/wounded priority.
- Engineers retain primary objective priority and gain frontline fortification logic.
- Field Ops can move toward nearby squad support clusters.
- Soldiers can reinforce the Frontline Director pressure sector.
- Existing suppression, cover, grenade, squad intelligence, shared targets, and vehicle avoidance remain.

MULTIPLAYER / PERFORMANCE
- Support deployables are spawned through authoritative RPCs.
- Maximum of 2 aid stations and 2 ammo crates per team at one time.
- Oldest same-type team support position is removed when the cap is exceeded.
- Support positions expire after 50 seconds.
- Stale deployable references are pruned server-side.
- Support deployables are cleared on round reset.
- No persistent particle systems or high-node-count effects were added.

TEST FOCUS
1. Launch headless server and confirm v14.0.0 / protocol 356 handshake.
2. Confirm --bots 0, --bots=0, and --no-bots still produce zero bots.
3. Confirm initial human spawn still uses safe base deployment and does not appear inside architecture.
4. As Medic, use class ability near teammates: verify revive/heal plus AID STATION spawn; INTERACT should heal teammates and award provider XP.
5. As Field Ops, use class ability: verify artillery still works and AMMO CRATE appears; INTERACT should add reserve ammo.
6. Shoot enemy support crates: they should take damage and be destroyable; friendly fire should not damage them.
7. Confirm support cap: deploying a third same-type team station removes the oldest, not map/environment content.
8. As Engineer, verify existing barricade deployment still works, Fortify repairs nearby allied barricades, and bridge/dynamite/defuse interactions still work.
9. Run bots and observe medics moving toward casualties, engineers keeping objective priority, Field Ops supporting clusters, and soldiers reinforcing pressure sectors.
10. Verify TAB scoreboard still renders above the normal HUD and existing weapons, vehicles, aircraft, FX, maps, and collisions remain unchanged.
11. Join a match after support crates have already been deployed; active aid/ammo positions should synchronize to the late-joining client.
