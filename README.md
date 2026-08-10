FRONTLINE: OBJECTIVE v10.7.0
MAJOR UPDATE — COMBAT PRESENTATION OVERHAUL

FOCUS
This phase does not rewrite either map. It improves the visual response of
combat while preserving the now-working Ruined City architecture collision.

BULLET IMPACTS
- existing impact/tracer systems retained
- additional lightweight impact debris/dust
- different impact coloration for player hits vs world surfaces
- short lifetimes
- no rigid-body debris

GRENADE EXPLOSIONS
- brighter fast explosion core
- expanding smoke volumes
- short non-shadowing explosion light
- directional debris chunks
- existing shockwave/audio/debris systems preserved

VEHICLE WEAPON IMPACTS
- tank/heavy weapon impacts now get a compact explosion presentation
- effect scales with existing impact_scale

VEHICLE DESTRUCTION
- larger explosion presentation layered over existing vehicle explosion/fire
- persistent physics debris is NOT added

PERFORMANCE
v10.7 introduces a hard client-side combat-presentation budget:
42 temporary effect roots maximum.

When the budget is exceeded, the oldest effect is removed first.
Effects are visual-only and never execute on a headless server.

No new:
- network snapshots
- rigid bodies
- shadow-casting explosion lights
- permanent debris
- expensive volumetric particle systems

PRESERVED
- Operation Black River
- Operation Ashen Streets / Ruined City
- true imported architecture collision from v10.6
- Jeeps / Sherman / Spitfire / Bf 109
- WWII soldiers
- Allied Mk 2 and Axis grenades
- existing weapon textures/models
- bots
- objectives/sectors
- TAB priority
- contextual E
- F6/F8
- --bots 0

Build: 10.7.0
Protocol: 351
