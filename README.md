FRONTLINE: OBJECTIVE v10.1.1
BOT ROUTE PARSER HOTFIX

SCREENSHOT ERROR
main.gd around line 5314:
Expected end of statement after expression, found ":" instead.

ROOT CAUSE
The v10.1.0 Map 2 bot-route insertion accidentally retained the old
bot_route_waypoint parameter/signature fragment after the new Ruined City
branch.

That produced a stray block beginning with:
player: Node3D,
route_index: int
) -> Vector3:

FIX
- removed the duplicate parameter/signature fragment
- retained the original Black River route body
- retained the new Ruined City route branch
- verified exactly one bot_route_waypoint() function exists in the region
- checked delimiter balance through the full bot-route block

UNCHANGED
- protocol remains 344
- server-authoritative map selection
- Operation Ashen Streets identity
- Ruined City tactical map
- Ruined City bot waypoints
- Black River bot waypoints
- vehicles / aircraft
- maps / map detail
- WWII soldiers
- Mk 2 grenade
- --bots 0

Build: 10.1.1
Protocol: 344
