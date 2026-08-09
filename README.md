FRONTLINE: OBJECTIVE v9.03.0
VEHICLE COMBAT + HUD + DESTRUCTION

NEW VEHICLE WEAPONS
TANK
- Mouse1 fires server-authoritative cannon
- 185 direct-hit damage
- ~120m range
- 1.7 second reload
- large impact explosion

AIRCRAFT
- Mouse1 fires server-authoritative forward machine guns
- 22 damage per hit
- ~150m range
- ~105ms fire interval
- lightweight impact effect

JEEP
- remains unarmed in this phase; mounted MG/passenger system is next.

VEHICLE HUD
While driving:
VEHICLE NAME · HP / MAX HP · SPEED KM/H
MOUSE1 weapon hint · E EXIT

DAMAGE / DESTRUCTION
- vehicles can damage enemy players
- armed vehicles can damage enemy vehicles
- destroyed vehicle movement/fire is disabled
- destruction spawns explosion + temporary fire
- driver is ejected safely
- effects are scaled by Low/Balanced/High through BattlefieldEffectsManager

PERFORMANCE
- server uses ray-based vehicle weapons rather than projectile rigid bodies
- no expensive shell physics
- existing ~10Hz vehicle snapshots retained
- Low mode keeps impact particle/light cost minimal

PRESERVED
- real Willys/Sherman/Spitfire/Bf109 GLBs
- vehicle direction fix
- weapon/arms hidden while driving
- vehicle seat lock and safe exit
- spawn movement fixes
- F6 and F8 quality controls
- --bots 0 / --bots=0 / --no-bots
- existing multiplayer/objective/performance systems

Build 9.03.0
Protocol 341
