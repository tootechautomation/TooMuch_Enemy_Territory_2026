FRONTLINE: OBJECTIVE v9.24.0
BOT COMBAT INTELLIGENCE + COVER + VEHICLE AWARENESS

VEHICLE AWARENESS
Bots now periodically inspect active enemy vehicles.
- enemy vehicles inside ~11m trigger an escape goal
- tanks produce a larger retreat distance
- destroyed/friendly vehicles are ignored
- checks are cached for 650ms to keep server cost low

LOW-HEALTH COVER
Bots at 42 HP or below attempt to use the existing server cover-position
system when an enemy is present.
- cover goal is cached for 1.8 seconds
- avoids recalculating cover every frame
- suppression cover still works
- vehicle escape remains higher priority

GRENADE DISCIPLINE
Bots now:
- throw only from ~9–21m
- check for friendly players within 6m of the intended impact point
- use grenades slightly less frequently
- wait longer before considering another throw

This reduces obvious friendly-fire grenade behavior and grenade spam.

COMBAT MOVEMENT
Emergency vehicle escape / suppression / low-health cover goals are no longer
overwritten by normal strafe/spacing movement in the same bot tick.

BOT ACCURACY
Bot accuracy now receives small penalties while:
- moving quickly
- suppressed

This makes firefights less robotic while retaining bot_skill scaling.

PERFORMANCE
- vehicle checks only every ~650ms per bot
- cover decisions cached ~1.8s
- grenade safety scans happen only when a bot is actually considering a throw
- no new pathfinding system
- no physics bodies
- no extra client networking

PRESERVED
- --bots 0 / --bots=0 / --no-bots
- v9.23.3 revive marker scope fix
- team awareness/callouts
- spatial audio
- effect budgets
- spawn safety
- all vehicle/aircraft systems
- F6/F8

Build: 9.24.0
Protocol: 341
