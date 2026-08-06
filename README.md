# Frontline: Objective

## Version 4.0.0 Sector Warfare & Tactical Map

### Three strategic sectors
- Village
- Rail Yard
- Fort
- Sectors capture over twelve seconds.
- Multiple teammates accelerate capture.
- Enemy presence creates a contested state.
- Holding two or more sectors restores one ticket every eighteen seconds.
- Sector ownership is synchronized to all clients.
- Each sector has a visible capture ring, label, and team-colored beacon.

### Tactical map
- Press M to open or close the full-screen tactical map.
- The map shows Village, Rail Yard, Fort, supply depot, river, and active objective.
- Sector codes update live:
  - A = Attackers
  - D = Defenders
  - N = Neutral
  - X = Contested
- Combat input pauses while the tactical map is open.

### Sector forward spawns
- Captured sectors provide validated forward-spawn candidates.
- Rally points still take first priority.
- Spawn validation prevents spawning inside walls, props, or invalid terrain.

### Large-map bot navigation
- Bots now follow route waypoints through the village, rail yard, center, and support lanes.
- Routes differ by team and squad role.
- Bots switch from strategic routes to the active objective when nearby.
- Existing artillery avoidance and combat behavior remain active.

### Compatibility
- Build: v4.0.0
- Network protocol: 341
- Explicit connection-message `+` retained.

Expected status: `Connected: v4.0.0 protocol 341`
