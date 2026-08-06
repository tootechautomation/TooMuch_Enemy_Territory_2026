# Frontline: Objective

## Version 5.3.0 Collision Integrity & Interior Combat

### Critical collision fix
Several imported visual buildings previously created collision only inside
graphical-client functions. The headless authoritative server therefore treated
those structures as empty space.

All major collision now builds in a shared server/client pass.

### Collision coverage
- Four imported village townhouses
- Stone church
- Rail warehouse
- Fort bunker
- Three rail cars
- Two half-tracks
- All v5.2 open-entry buildings and tunnels remain collision-enabled

### Interior-ready shells
Imported buildings now use wall, floor, roof, lintel, and doorway collision
pieces rather than one solid invisible box. Doorways remain traversable while
brick and plaster walls block players and bullets.

### Interior combat
- Added server-authoritative crate and barrier cover inside eight expanded-map
  buildings.
- Cover breaks direct interior sightlines.
- Collision exists identically on the VPS and local client.

### Validation
A startup validation pass checks every registered structure proxy and reports
any structure that contains no CollisionShape3D.

Set `collision_debug_enabled = true` before startup to display translucent green
collision proxies on graphical clients.

### Compatibility
- Build: v5.3.0
- Protocol: 341
- Explicit connection-message `+` retained.

Expected status: `Connected: v5.3.0 protocol 341`
