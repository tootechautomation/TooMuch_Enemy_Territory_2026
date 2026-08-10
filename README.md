FRONTLINE: OBJECTIVE v9.23.0
TEAM AWARENESS + OBJECTIVE CALLOUTS + PING RESTRAINT

SQUAD PINGS
Existing squad pings are now quality/distance aware.

LOW/LAPTOP:
- max 2 simultaneous ping markers
- visible to roughly 42m

BALANCED:
- max 4
- roughly 62m

HIGH:
- max 6
- roughly 78m

Ping markers now show sender + approximate distance and expire after 3.8 sec.

IMPORTANT FIX
show_squad_ping() no longer tries to generate a new global kill-feed RPC from
every receiving client. This removes redundant ping-related message/network
noise.

TEAM CALLOUTS
Short mission-banner callouts are now generated for important events:
- bridge complete / bunker defense begins
- dynamite charge armed
- overtime
- teammate down
- teammate revived
- squad mark received

Callouts are filtered by team where appropriate and duplicate keys are
cooldown-limited.

REVIVE AWARENESS
Friendly downed-player markers now show:
✚ REVIVE · XXm

Distance culling:
- Low ~20m
- Balanced ~30m
- High ~38m

This reduces distant label clutter while preserving nearby Medic awareness.

PERFORMANCE
- no new physics
- no continuous network stream
- ping count is hard capped
- callouts are event-driven only
- duplicate callout suppression
- no new dynamic lighting/particles

PRESERVED
- v9.22 spatial audio / surface footsteps / vehicle engines
- v9.21 effect budgets
- v9.20 spawn safety / U unstuck
- visibility/environment work
- first-person/HUD/combat systems
- destructible streets
- all vehicle and aircraft gameplay
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.23.0
Protocol: 341
