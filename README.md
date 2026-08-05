# Frontline: Objective

## Version 2.0.0 bot lifecycle and combat AI

Fixed:

- Bots no longer remain as permanent dead/downed bodies.
- Bots are eliminated immediately when health reaches zero.
- Dead bot collision is disabled.
- Dead bots disappear from all clients.
- Bots return on the next respawn wave with collision restored.

Improved bot behavior:

- Attackers advance toward the active objective.
- Defenders move to defensive positions.
- Engineers travel to and interact with objectives.
- Medics move toward and revive downed teammates.
- Bots search for enemies, approach, retreat, and strafe.
- Scouts maintain longer engagement distance.
- Bots attempt to jump over low obstacles.
- Stuck detection changes direction and triggers a jump.
- Bots reload automatically.
- Bots use class abilities when useful.
- Bot accuracy changes when aiming.

Install the same package on Windows and Linux.

Expected HUD:

```text
Connected: v2.0.0 protocol 200
```
