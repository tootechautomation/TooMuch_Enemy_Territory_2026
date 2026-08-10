FRONTLINE: OBJECTIVE v9.27.0
CONTEXTUAL INTERACTION + E-KEY RELIABILITY

CONTEXT PROMPT
A small interaction prompt now appears below the crosshair only when an
action is actually available.

Examples:
E · EXIT VEHICLE
E · ENTER M4 SHERMAN · DRIVER
E · TAKE AMMO
E · SWAP PRIMARY WEAPON
E · RESUPPLY AMMO
E · REVIVE PLAYERNAME
E · BUILD BRIDGE · 4/10
E · ARM DYNAMITE
E · DEFUSE CHARGE · 2/5

INTERACTION PRIORITY
The prompt mirrors the server's actual interaction order:

1. vehicle entry/exit
2. battlefield weapon/ammo pickup
3. fixed resupply station
4. Medic revive
5. Engineer objective action

This means the prompt describes the same action the server will attempt first.

E KEY FIX
Previously the dedicated physical E handler sent only
request_vehicle_interact(). The generic interact path separately handled
pickups/revive/objectives.

Physical E now sends the unified request_player_interact() immediately.

The server still validates:
- range
- vehicle seat
- player state
- team/class
- objective state
- pickup/resupply availability

CONTROLLER / REMAPPED INPUT
The existing held interact action remains available as a fallback. Its hold
threshold is slightly longer to avoid a keyboard E tap producing duplicate
RPCs.

HUD RESTRAINT
The context prompt automatically hides during:
- TAB scoreboard
- cinema mode
- tactical map
- spawn/class menu
- death/downed state

PERFORMANCE
The prompt is evaluated only with the already-throttled HUD update, not every
render frame.

No new physics, collision, particles, or network stream.

PRESERVED
- v9.26 weapon handling
- v9.25 TAB scoreboard priority
- v9.24 bot combat intelligence
- team/revive awareness
- spatial audio
- effect budgets
- spawn safety
- all vehicles/aircraft
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.27.0
Protocol: 341
