FRONTLINE: OBJECTIVE v8.84.0
RESUPPLY STATIONS + PICKUP UX

NEW GAMEPLAY
Three fixed battlefield resupply points are now available:
- Bunker Ammo
- Depot Supplies
- Command Supply

Use the existing INTERACT action while close to a station.

Each successful station use can provide:
- approximately two magazines of reserve ammunition for the CURRENT weapon
- +1 grenade, up to the normal 2-grenade capacity
- +1 smoke grenade, up to the normal 1-smoke capacity

A personal 8-second resupply cooldown prevents repeated spam.

INTERACTION PRIORITY
INTERACT now checks in this order:
1. nearby dropped weapon/ammo pickup
2. nearby fixed resupply station
3. class interactions such as Medic revive / Engineer interaction

This prevents a resupply crate from stealing an intended dropped-weapon pickup.

PICKUP UX
- dropped-weapon labels now fade out beyond roughly 7m
- pickup ground rings fade out beyond roughly 10m
- resupply prompts are also proximity-limited
- reduces HUD/world clutter across the map

PRESERVED FROM v8.83
- only the ACTIVE weapon drops on death
- same weapon on ground is scavenged for ammo
- different primary/secondary weapons swap into the matching slot
- cross-faction MP40 / Thompson / P38 / TT pickup rendering
- separate loose-ammo pouch
- 55-second dropped-equipment cleanup

ALSO PRESERVED
- working Axis P38 orientation
- Mouse2 shoulder zoom
- persistent crosshair
- collision / objectives / networking
- all performance and visual systems

Build: 8.84.0
Network protocol: 341
