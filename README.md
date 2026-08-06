# Frontline: Objective

## Version 5.4.0 Navigation & Collision Reliability

### Physics contract
- Players now use collision layer 2 and collision mask 1.
- All world structures explicitly use collision layer 1 and mask 1.
- Bot obstacle rays explicitly query world layer 1.
- Spawn validation uses an oversized capsule and larger safety margin.

### Spawn fix
The enclosed staging buildings introduced in v5.2 overlapped valid spawn
capsules and trapped players and bots inside walls.

They were replaced with open deployment courtyards:
- Solid floor
- Rear protective wall only
- Three low cover pieces
- Open front and side exits
- Spawn positions moved farther outward and away from geometry

### Bot navigation
- Added team-specific waypoint routes through the expanded map.
- Bots use waypoints until reaching the active objective area.
- Added a 1.8-second jump cooldown.
- Bots jump only when the low ray is blocked and the high ray is clear.
- Stuck bots strafe and rotate rather than repeatedly jumping.
- Severely stuck bots request a validated server recovery position.
- Recovery has a five-second cooldown.

### Collision
- All v5.3 structure collision remains.
- Wall, doorway, church, warehouse, bunker, rail-car, vehicle, tunnel, and
  expanded-building collision remains server authoritative.

### Compatibility
- Build: v5.4.0
- Protocol: 341
- Explicit connection-message `+` retained.

Expected status: `Connected: v5.4.0 protocol 341`
