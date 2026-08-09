FRONTLINE: OBJECTIVE v8.95.0
MENU/HUD STATE FIX + OBJECTIVE SANITY + REINFORCEMENT PRESENTATION

FIX 1 — SERVER BROWSER / MENU OVERLAP
The v8.93/v8.94 objective HUD was still drawing while the server browser,
connection form or profile/menu controls were visible.

v8.95 now hides the match HUD whenever:
- server browser is visible
- connect/connection UI is visible
- profile/settings menu is visible
- main menu is visible
- team/class selection menu is visible

The HUD reappears only when the local player exists in the active match.

FIX 2 — IMPOSSIBLE CAPTURE PERCENTAGES
Observed example:
    Capture progress -2917%

The HUD now normalizes objective internals before display:
- supports 0..1 values
- supports 0..100 values
- handles signed contested accumulation
- clamps final display to 0..100%
- rejects non-finite values

The gameplay objective variable itself is NOT modified.

NEXT PHASE — REINFORCEMENT READABILITY
Added a lightweight client-only reinforcement status panel:
- identifies local side (ALLIES / AXIS)
- shows next spawn-wave countdown
- uses authoritative remaining time if exposed by the game
- otherwise mirrors the existing wave cadence for display
- automatically hides in menus

This does not alter actual respawn scheduling.

PRESERVED
- v8.94 structural collision guard
- v8.94 first-person procedural arm/hand fallback
- HUD safe-area positioning
- active-weapon-only drops
- same-weapon ammo scavenging
- cross-faction weapon swaps
- resupply stations
- casualty persistence
- contextual pickup HUD
- shell-casing feedback
- F8 Low/Balanced/High performance stack
- remote-player LOD
- memory / CPU / GPU scalability
- working Axis P38 orientation
- Mouse2 zoom + persistent crosshair
- collision/objective/server authority/networking

Build: 8.95.0
Network protocol: 341
