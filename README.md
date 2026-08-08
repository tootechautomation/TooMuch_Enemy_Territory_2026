FRONTLINE: OBJECTIVE v8.91.0
MEMORY FOOTPRINT + ASSET SCALABILITY

WHY THIS PHASE
v8.89 reduced GPU load.
v8.90 reduced CPU/thermal/frame-pacing load.
v8.91 reduces the amount of decorative scene data that needs to stay relevant
at once on lower-spec machines.

LOW / LAPTOP
- microdetail draw range tightened to roughly 11m
- medium decorative props tightened to roughly 34m
- microdetail shadows remain disabled
- casualty detail only retained at short range
- dropped weapon world-model detail only retained near the player
- resupply marker lights disabled
- lower GeometryInstance3D LOD bias where supported
- static casualty/resupply nodes are fully non-processing

BALANCED
- microdetail roughly 20m
- medium props roughly 55m
- pickup/casualty visual range reduced moderately
- lower LOD bias than High

HIGH
- preserves full approved visual presentation
- standard LOD bias
- previous visual ranges remain authoritative

IMPORTANT
No gameplay-critical structures are removed:
- walls
- collision
- terrain navigation
- objective geometry
- players
- weapons in use
- gameplay smoke
- pickups themselves
- resupply functionality

This phase only makes far-away DECORATIVE detail less expensive.

QUALITY SYSTEM
F8 still cycles:
LOW / LAPTOP -> BALANCED -> HIGH

The setting remains persistent and v8.90 adaptive downgrade behavior remains.

PRESERVED
- all v8.90 CPU/frame pacing changes
- v8.89 GPU presets
- shell casing feedback
- active-weapon-only drops
- matching weapon ammo scavenging
- cross-faction swaps
- contextual pickup HUD
- resupply stations
- casualty persistence
- Axis P38 orientation
- Mouse2 shoulder zoom
- persistent crosshair
- collision / objectives / networking

Build: 8.91.0
Network protocol: 341
