FRONTLINE: OBJECTIVE v9.21.0
EFFECT BUDGET + DISTANCE CULLING + LONG-MATCH PERFORMANCE

WHY
The game now has substantially more combat and atmosphere effects than the
early builds. During sustained firefights, transient visual nodes can become a
larger cost than the underlying hitscan gameplay.

v9.21 adds local visual budgets. Gameplay damage/network authority is unchanged.

HARD TRANSIENT CAPS

LOW / LAPTOP
- up to 10 active tracers
- up to 8 active bullet impacts
- up to 4 muzzle flashes
- up to 8 larger explosion/fire effects

BALANCED
- 20 tracers
- 18 impacts
- 8 muzzle flashes
- 14 larger effects

HIGH
- 32 tracers
- 28 impacts
- 12 muzzle flashes
- 20 larger effects

When a budget is exceeded, the oldest purely visual effect is removed first.

DISTANCE CULLING
Effects outside useful viewing distance are not created locally.

Approximate Low/Laptop limits:
- tracers ~45m
- bullet impacts ~34m
- vehicle muzzle flashes ~38m
- explosions ~55m
- ambient fire ~34m
- ambient smoke ~38m

Balanced/High progressively extend these ranges.

MAINTENANCE PASS
Every 0.5 seconds the BattlefieldEffectsManager:
- removes invalid/stale effect references
- trims arrays to the active quality budget
- removes oldest visual-only effects if necessary

This prevents stale references from building up during long matches.

IMPORTANT
This is VISUAL culling only.
The server still resolves:
- hitscan
- damage
- explosions
- vehicle weapons
- objective damage
- destruction

A distant effect not being rendered does not change gameplay.

PERFORMANCE
No additional network traffic.
No additional physics.
No extra collision.
The effect-budget maintenance pass runs only twice per second.

PRESERVED
- v9.20 spawn safety / U unstuck / below-map recovery
- v9.19 visibility and route readability
- v9.18.1 parser-safe environment pass
- first-person fixes
- HUD/combat feedback
- destructible streets
- all vehicles and aircraft
- F6/F8
- --bots 0 / --bots=0 / --no-bots

Build: 9.21.0
Protocol: 341
