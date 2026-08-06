# Frontline: Objective

## Version 5.5.2 Ground Bounds & Fall Recovery

### Ground collision fix
The expanded gray roads and terrain overlays were graphical surfaces without
matching authoritative collision beyond the original map footprint.

This update adds shared client/server collision under:
- Central battlefield
- Northern urban lane
- Southern flank
- Attacker and defender staging areas
- Western and eastern outer approaches
- Expanded corner routes

### Playable boundary
Added thin authoritative perimeter walls at the true playable limits. Players
can reach visible walls and roads but cannot continue into unsupported scenery.

### Out-of-bounds recovery
Players and bots falling below y=-12 are moved to the nearest validated spawn
position. The sewer remains safe because its floor is around y=-3.3.

Recovery:
- Runs only on the authoritative server
- Has a 2.5-second cooldown
- Clears velocity
- Resets bot routing after recovery

### Compatibility
- Build: v5.5.2
- Protocol: 341
- Explicit connection-message `+` retained.
- All v5.5.1 geometry-alignment and parser fixes remain included.

Expected status: `Connected: v5.5.2 protocol 341`
