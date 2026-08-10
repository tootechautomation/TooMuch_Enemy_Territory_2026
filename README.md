FRONTLINE: OBJECTIVE v9.15.0
OBJECTIVE READABILITY + HUD CLEANUP + UI PERFORMANCE

OBJECTIVE HUD CLEANUP
The top match-status line has been shortened.

Stage 1 example:
BRIDGE 4/10 · TICKETS 78-76 · VEHICLE SUPPORT

Bunker example:
BUNKER 64% · CP ATK · TICKETS 71-68 · TANK SUPPORT

The detailed emplacement/sector/destructible-cover information remains
available internally through extended_match_status_text(), but is no longer
forced into the primary objective line every update.

TACTICAL VEHICLE MARKERS
- Low/Laptop marker range reduced to ~42m
- Balanced/High range ~52m
- distant markers show symbol + distance only
- close markers show vehicle type + distance
- markers fade toward the edge of their visibility range

This reduces both clutter and unnecessary label rendering.

UI PERFORMANCE THROTTLING
Previously several UI systems updated every rendered physics frame:
- HUD text
- vehicle HUD
- role HUD
- reinforcement HUD
- team identity HUD
- vehicle tactical markers
- radar

v9.15 groups these into quality-aware update intervals.

LOW/LAPTOP:
- HUD ~12 updates/sec
- tactical vehicle markers ~5.5 updates/sec
- radar ~7 updates/sec

BALANCED:
- HUD ~20 updates/sec
- markers ~10 updates/sec
- radar ~12.5 updates/sec

HIGH:
- HUD ~28 updates/sec
- markers ~13 updates/sec
- radar ~18 updates/sec

Camera, movement, weapon animation and combat feedback remain per-frame.

PRESERVED
- v9.14 infantry damage/suppression/effect scaling
- v9.13.2 tracer scope fix
- battlefield tracers/impact FX/smoke/fire
- vehicle camera collision and safe exits
- destructible streets
- all vehicle and aircraft systems
- real vehicle GLBs
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.15.0
Protocol: 341
