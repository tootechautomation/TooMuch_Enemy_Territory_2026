FRONTLINE: OBJECTIVE v8.90.0
CPU LOAD + FRAME-PACING OPTIMIZATION

THIS PHASE COMPLEMENTS v8.89
v8.89 reduced GPU rendering cost.
v8.90 targets client CPU load, laptop thermals and unstable frame pacing.

NEW CLIENT PERFORMANCE GOVERNOR
- LOW caps rendering at 60 FPS
- BALANCED caps rendering at 90 FPS
- HIGH caps rendering at 165 FPS

The frame caps prevent laptops from wasting power/heat trying to render far
above the display/gameplay requirement.

ADAPTIVE PERFORMANCE ASSIST
If sustained client FPS remains under roughly 38 FPS for about six seconds:
- HIGH automatically drops to BALANCED
- BALANCED automatically drops to LOW

The system NEVER automatically raises quality again, preventing distracting
quality oscillation during gameplay. Users can still press F8 manually.

LOW / LAPTOP IMPROVEMENTS
- internal 3D scale reduced from 72% to 67%
- viewport occlusion culling enabled where supported
- environmental motion controller stops processing
- rain ripple controller stops processing
- nonessential dust/ember/drip/splash/haze processing is suspended
- low shell-casing cleanup reduced to ~3 seconds
- 4-casing visual budget remains
- 60 FPS cap reduces battery/thermal load

BALANCED
- 90 FPS cap
- 88% internal render scale
- moderate particles/shadows/SSAO from v8.89
- casing cleanup ~4 seconds

HIGH
- 165 FPS cap
- full visual presentation
- normal casing cleanup ~5 seconds

GAMEPLAY SAFETY
NOT reduced or changed:
- physics tick behavior
- movement
- weapon fire rate
- hit registration
- objective logic
- multiplayer/server authority
- bot/server gameplay simulation
- gameplay smoke
- collision geometry

This means a Low-quality laptop client sees fewer cosmetic effects but still
participates in the exact same authoritative match.

PRESERVED
- v8.89 quality presets/F8 control
- v8.88 weapon handling feedback
- active-weapon-only drops
- ammo scavenging
- cross-faction weapon swaps
- contextual pickup HUD
- resupply stations
- casualty persistence
- working Axis P38 orientation
- Mouse2 zoom + persistent crosshair
- all objective/collision/network systems

Build: 8.90.0
Network protocol: 341
