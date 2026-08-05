# Frontline: Objective

## Version 1.4.5 validated spawning

The previous system selected raw coordinates without checking the map.

This build adds:

- Safer base spawn positions away from the river, cover blocks, and walls
- Downward floor raycasts
- Walkable-surface normal checks
- Full standing-capsule clearance checks
- Occupied-player distance checks
- Multiple alternate and fallback positions
- Emergency team-ground spawn as a last resort
- Server logs showing every final spawn coordinate

Install the same package on both Windows and Linux.

Expected HUD:

```text
Connected: v1.4.5 protocol 145
```

Expected server log:

```text
Spawned Player123 peer=123 team=0 at (-16.0, 0.96, 0.0)
```
