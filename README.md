FRONTLINE: OBJECTIVE v9.19.0
VISIBILITY / LIGHTING BALANCE + ROUTE READABILITY

WHY
Recent gameplay has been playable but the environment still tends to look
washed-out and hazy. v9.19 reduces that haze while preserving atmosphere.

LOW / LAPTOP
- volumetric fog OFF
- glow OFF
- low conventional fog density
- higher contrast
- slightly darker ambient fill
- sun shadows disabled
- new route detail capped near 30m

BALANCED
- much lighter volumetric fog than earlier builds
- reduced glow intensity
- stronger scene contrast
- shorter shadow distance
- route detail around 45m

HIGH
- atmospheric fog retained
- volumetric density still less than half of the old default
- moderate glow rather than the earlier strong bloom
- shadow distance around 82m
- route detail around 58m

ROUTE READABILITY
New non-colliding visual-only details:
- low stone edge strips along the primary central route
- four muted roadside approach stones around the bridge area

These are intentionally period-neutral masonry rather than bright arcade arrows.

PERFORMANCE
- Low disables volumetric fog and sun shadows
- no new collision
- no dynamic lights
- no physics objects
- route geometry is tiny BoxMesh detail with distance culling

PRESERVED
- v9.18.1 parser-safe environment pass
- v9.17 first-person visibility fixes
- HUD/combat feedback
- destructible streets
- all vehicle/aircraft systems
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.19.0
Protocol: 341
