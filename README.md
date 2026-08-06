# Frontline: Objective

## Version 5.5.0 Geometry Alignment & Interior Route Polish

### Townhouse collision correction
The v5.3/v5.4 townhouse proxies used broad full-building shells. Those shells
were larger than the rendered townhouse assets, causing invisible walls in
front of red brick façades while still missing portions of plaster walls.

They have been replaced with model-specific aligned collision:

- Thin front-façade segments
- Door-sized openings
- Door lintels
- Inset left and right side walls
- Rear wall aligned to the rendered depth
- No broad roof or floor proxy around imported façades

### Gray wall correction
Added authoritative collision for the western plaster wall and adjoining corner
wall visible near the attacker staging route.

### Landmark adjustment
Church, warehouse, and bunker collision dimensions were reduced slightly to
better match their visible footprints.

### Collision audit
Startup validation now calculates each registered proxy's horizontal extent and
warns about suspiciously oversized collision roots.

### Bot route polish
- Added centered approach waypoints near village entrances.
- Increased waypoint arrival radius to reduce doorway oscillation.
- Bot obstacle rays extend slightly farther.
- Bots only jump obstacles whose measured hit height is below 0.75 meters.
- Tall walls trigger route recovery instead of jump attempts.

### Compatibility
- Build: v5.5.0
- Protocol: 341
- Explicit connection-message `+` retained.

Expected status: `Connected: v5.5.0 protocol 341`
