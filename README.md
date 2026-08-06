# Frontline: Objective

## Version 3.7.0 Tactical Operations

### Supply depot side objective
- A new supply depot is located on the western flank.
- Players capture it by occupying its radius.
- Multiple teammates accelerate capture.
- Enemy presence makes it contested.
- Capturing the depot immediately restores four tickets.
- The controlling team gains one ticket every twelve seconds.
- World labels, lighting, mission banners, and the operations HUD show its state.

### Team rally points
- Field Ops presses V to deploy a team rally point.
- Each team may have one active rally point.
- A new rally replaces the previous team rally.
- Rally points last 45 seconds.
- Enemy players within eight meters contest the rally.
- Uncontested rally points take priority for reinforcement-wave respawns.
- Spawn validation remains active around rally points.

### Tactical AI
- Bots detect pending artillery danger.
- Bots inside the danger radius move away from the impact position.
- Existing squad lanes, smoke blocking, and class behavior remain active.

### Mission presentation
- Major captures, neutralizations, and rally deployments create center-screen banners.
- Tactical HUD now displays supply-depot ownership alongside command-post and gun status.

### Compatibility
- Build: v3.7.0
- Protocol: 341
- The connection-failure message uses explicit `+` string concatenation.

Expected status: `Connected: v3.7.0 protocol 341`
