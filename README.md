# Frontline: Objective

## Version 6.1.0 Authoritative Bot Drive & PBR Surface Pass

### Bot movement
The custom bot velocity path has been removed from active use.

Bots now feed a forward movement command into the same `_server_simulate()`
function used by human players. This gives bots the same CharacterBody3D
movement, collision, gravity, jumping, floor handling, and server authority.

Bots request validated recovery after two seconds without displacement.

### Original PBR texture pack
Added original generated textures for Allied and Axis uniform cloth, red brick,
aged plaster, cobblestone, wood, and aged metal. These assets are original and
do not copy Wolfenstein artwork.

### Character realism
Procedural soldiers now use fabric texture detail, but they remain procedural
geometry. Truly realistic people require licensed rigged humanoid models.

Optional model slots:
- `assets/models/allied_soldier.glb`
- `assets/models/axis_soldier.glb`

A model requirements document is included.

### Compatibility
- Build: v6.1.0
- Protocol: 341
- Explicit connection-message `+` retained
- Cache-independent VPS startup retained

Expected status: `Connected: v6.1.0 protocol 341`
