# Frontline: Objective

## Version 5.8.0 AI Systems Refactor & Cover Tactics

### Parser fix
The v5.7 cover helper was inside `main.gd`, which extends `Node`. It called
`get_world_3d()`, a method only available on Node3D-derived objects.

Cover evaluation now runs in `scripts/ai/tactical_director.gd` and receives the
bot Node3D directly. It uses:

```gdscript
var world: World3D = bot.get_world_3d()
```

### AI refactor
Moved these responsibilities out of `main.gd`:
- Class-aware tactical anchor selection
- Stage-aware attack and defense positions
- Suppression cover candidate generation
- Floor validation
- Cover visibility scoring

`main.gd` now exposes small compatibility wrappers so existing player and bot
code continues to work.

### Improved cover tactics
Suppressed bots now evaluate four candidate escape positions. Candidates score
higher when:
- A world object blocks line of sight from the threat
- The position increases distance from the attacker
- The travel distance is reasonable

Bots cache their chosen cover briefly instead of recalculating every frame.

### Compatibility
- Build: v5.8.0
- Protocol: 341
- Explicit connection-message `+` retained
- Cache-independent VPS startup retained
- v5.7 class behavior and v5.6 surface footsteps retained

Expected status: `Connected: v5.8.0 protocol 341`
