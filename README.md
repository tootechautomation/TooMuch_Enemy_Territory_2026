# Frontline: Objective

## Version 5.6.0 Exact Structure Collision & Surface Feedback

### Exact imported collision
The red-brick and plaster buildings no longer use hand-measured collision
proxies. Collision is generated directly from the imported GLB mesh geometry.

Exact mesh collision now covers:
- Two intact townhouses
- Two ruined townhouses
- Stone church
- Rail warehouse
- Concrete bunker

The same PackedScene resources are preloaded on graphical clients and the
headless VPS. Each MeshInstance3D generates trimesh collision, and every
generated StaticBody3D is assigned to world collision layer 1.

### Removed approximate proxies
Removed the previous townhouse, church, warehouse, and bunker shell collision.
The remaining authored collision is limited to:
- Gray/plaster route-wall segments
- Rail cars and half-tracks
- Interior cover
- Expanded roads, terrain, and perimeter
- Sewer and modular map buildings

### Startup verification
The server prints:
`Exact structure collision ready: <name> generated=<n> bodies=<n>`

Any structure that fails to generate collision reports an error.

### Surface feedback
Footstep audio now changes pitch and volume according to detected surfaces:
- Metal
- Wood
- Stone/brick/concrete
- Gravel
- Ground/mud

This uses existing project audio and does not add external copyrighted sounds.

### Compatibility
- Build: v5.6.0
- Protocol: 341
- Explicit connection-message `+` retained.
- All v5.5.2 ground collision and fall recovery remain.

Expected status: `Connected: v5.6.0 protocol 341`
