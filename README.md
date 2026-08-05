# Frontline: Objective

## Version 2.3.0 tactical combat and scoring

This combined milestone adds:

### Tactical HUD
- Objective direction: AHEAD, LEFT, RIGHT, or BEHIND
- Live distance to the active objective
- Enemy grenade proximity warning
- Damage numbers with remaining enemy health

### Combat scoring
- Ten-second damage-contribution tracking
- Assist XP and assist notifications
- Kill-streak feedback at three and five eliminations
- Streak reset on death

### Movement
- Server-authoritative fall damage
- Damage scales from hard landing to lethal impact

### Bots
- Configurable bot difficulty:
  `--bot-skill 0.5` through `--bot-skill 2.0`
- Skill multiplier changes bot accuracy
- Default remains `1.0`

Example server:

```bash
flatpak run org.godotengine.Godot --headless --path .   --server --port 27960 --bots 8 --bot-skill 1.25
```

Install the same package on Windows and Linux.
