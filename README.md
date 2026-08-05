# Frontline: Objective

## Version 3.0.0 Frontline Operations

This is a major round-structure expansion.

### Command post
- A secondary command post unlocks after the bridge is built.
- Living players capture it automatically by occupying its radius.
- Multiple players accelerate capture.
- Opposing players contest and freeze capture.
- Ownership grants a forward spawn and faster reinforcement waves.
- Capturing the post restores five team tickets.
- Bots actively contest the post.

### Reinforcement tickets
- Both teams begin with 80 tickets.
- Each elimination consumes one ticket from the victim's team.
- Players cannot respawn after their team reaches zero tickets.
- A team loses when it has zero tickets and no living players.
- Tickets appear in the HUD, objective text, and scoreboard.

### Forward spawns
- The team controlling the command post respawns near the front line.
- Spawn validation remains active for forward positions.
- Losing the command post returns the team to its original spawn.

### Overtime
- The round enters overtime when time expires during:
  - an armed charge,
  - a contested command post, or
  - an attacker pressing the active primary objective.
- Overtime ends when defenders fully secure the battlefield.

### Battlefield atmosphere
- Lighting gradually shifts toward dusk during the round.
- Ambient energy and sun angle change with match progress.
- Command post lighting changes by ownership and contest state.

Expected status:

```text
Connected: v3.0.0 protocol 300
```
