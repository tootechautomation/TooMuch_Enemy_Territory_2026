# Frontline: Objective

## Version 6.1.1 Stability Hotfix

### Scoreboard
Fixed an infinite recursion in `round_awards_text()`. The function appended
itself to its own output, causing the stack overflow whenever TAB requested the
scoreboard.

TAB now requests a finite scoreboard and awards summary.

### Bot movement
Removed the competing second route system and timer-driven waypoint changes.

Bots now:
- Use one authoritative route goal
- Advance waypoints only after reaching them
- Move directly in world space with CharacterBody3D
- Rotate smoothly toward the active goal
- Strafe after 1.5 seconds of physical blockage
- Request validated recovery after a prolonged stall
- Apply a bounded server-side nudge only if recovery returns the same position

### Visual realism
The included generated textures improve material detail, but procedural
capsules and boxes cannot match the earlier concept render.

A full realism asset plan is included at:
`assets/models/REALISM_ASSET_PLAN.md`

The next visual phase requires licensed rigged soldier models and a modular
environment kit. Texture-only changes are insufficient.

### Compatibility
- Build: v6.1.1
- Protocol: 341
- Explicit connection-message `+` retained
- Cache-independent VPS startup retained

Expected status: `Connected: v6.1.1 protocol 341`
