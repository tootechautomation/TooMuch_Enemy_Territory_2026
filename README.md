FRONTLINE: OBJECTIVE v9.18.0
WWII ENVIRONMENT COHESION + MATERIAL/DETAIL PASS

GOAL
Recent gameplay screenshots still showed large flat/bright surfaces even though
the underlying world has many visual passes. v9.18 adds a conservative final
cohesion layer rather than replacing map collision or gameplay geometry.

EXISTING MATERIAL RETUNING
Only existing StandardMaterial3D overrides on world/environment meshes are
adjusted. Imported PBR assets are left alone.

Name-based world tuning:
- brick/ruins: darker warmer masonry
- concrete/bunker/fort: darker neutral concrete
- roads/ground/cobble: reduced brightness and higher roughness
- roof/slate: darker roof values
- wood/crates/timber: darker weathered wood

Players, weapons, first-person arms, vehicles, tracers, pickups and HUD-related
meshes are explicitly excluded.

STREET DEFINITION
Thin non-colliding curb/edge strips now break up large flat road/ground areas.
They are visual only and do not affect movement or vehicle collision.

ARCHITECTURAL DEPTH
Added small low-cost visual cues:
- masonry posts
- timber braces
- shallow facade recesses
- stone lintels

These help flat procedural facades read more like buildings instead of boxes.

PERFORMANCE / DISTANCE CULLING
Every new detail uses GeometryInstance3D visibility ranges.

LOW/LAPTOP:
- keeps major curb/street definition
- hides facade recesses and minor posts/braces
- caps new-detail distance around 34m

BALANCED:
- enables all new detail
- facade/minor detail around 42-45m

HIGH:
- extends detail visibility to roughly 58-60m

No new collision bodies.
No new dynamic lights.
No shadows on added detail.
No extra physics processing.

PRESERVED
- v9.17 first-person visibility fix
- v9.15 HUD performance/objective cleanup
- v9.14 combat feedback
- v9.13.2 tracer fixes
- destructible streets
- all vehicles/aircraft
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.18.0
Protocol: 341
