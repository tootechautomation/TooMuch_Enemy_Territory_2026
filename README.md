# Frontline: Objective

## Version 7.2.0 Weapon Attachment, Imported Collision & Replacement Controls

### Third-person weapons
Optional Allied rifle, Axis rifle and service-pistol GLBs attach to rigged
character hand sockets. Weapon visuals update when the equipped slot changes.

### Imported environment collision
External environment models now:
- Use authored StaticBody3D collision when available
- Generate trimesh collision when configured and authored collision is absent
- Receive world collision layer 1 and mask 1
- Report collision status during startup

### Safe visual replacement
Procedural stand-ins are hidden only when:
1. The real GLB loads successfully
2. The imported model has valid collision

This prevents real-looking decorative models from leaving passable walls.

### Asset diagnostics
Startup now prints an external asset report showing:
- Available character slots
- Available weapon slots
- Available environment slots
- Instantiated external nodes
- Collision results for imported environment assets

### Compatibility
- Build: v7.2.0
- Protocol: 341
- Explicit connection-message `+` retained
- Missing assets continue using procedural fallbacks

Expected status: `Connected: v7.2.0 protocol 341`
