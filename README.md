FRONTLINE: OBJECTIVE v11.0.0
MAJOR GAMEPLAY UPDATE — COMBAT FEEL + AI + AUDIO + FEEDBACK

THIS IS A CONSOLIDATED RELEASE
v11 is intentionally a larger gameplay phase instead of another sequence of
tiny one-off patches.

MAP / ENVIRONMENT FREEZE
This update DOES NOT change:
- Operation Black River geometry
- Ruined City geometry
- buildings
- imported architecture collision
- vehicle placement
- objectives / sector placement

COMBAT FEEL
- near-miss bullets now create server-authoritative suppression
- suppression radius: approximately 2.35m around the shot path
- closer near misses produce longer suppression
- direct hits are excluded from duplicate near-miss suppression
- existing suppression accuracy penalty remains

DAMAGE FEEDBACK
- directional damage indicator lasts longer
- damage direction adds a subtle LOCAL camera response
- camera feedback does not alter server aim or movement physics
- headshot marker persists slightly longer
- standard hit marker is slightly easier to read

BOT COMBAT
- suppressed bots commit to cover for a short period
- suppressed bots are less likely to immediately fire back
- existing accuracy suppression penalty remains
- existing medic / engineer / grenade / vehicle avoidance logic preserved
- existing map-specific bot routes preserved

FOOTSTEPS
- sprint cadence tightened
- crouched footsteps are slower and substantially quieter
- sprint footsteps are slightly louder
- subtle per-step pitch variation reduces repetitive audio
- existing ground/gravel/stone/wood/metal selection remains
- existing remote-footstep distance optimization remains

RESPAWN / DEATH FLOW
- normal reinforcement-wave respawns now trigger the same spawn-protection
  presentation used by forced/team respawns
- respawn HUD briefly confirms REINFORCEMENTS DEPLOYED
- existing death/reinforcement panel remains

COMBAT PRESENTATION FROM v10.7 PRESERVED
- bullet impact dust/debris
- grenade smoke/blast presentation
- heavy weapon impact presentation
- vehicle destruction effects
- 42-effect visual budget

PRESERVED
- Black River
- Ruined City
- true architecture collision
- Jeep / Sherman / Spitfire / Bf 109
- WWII Allied/German soldiers
- Allied Mk 2 / Axis grenade
- weapons/textures
- map-aware HUD and scoreboard
- TAB priority
- contextual E interaction
- F6/F8
- --bots 0 / --bots=0 / --no-bots
- server-authoritative map selection

Build: 11.0.0
Protocol: 352
