# Frontline: Objective

## Version 7.3.0 Asset Validation, LOD & Runtime Replacement

### Asset validation
Imported characters are checked for meshes, skeletons, animations, recognized
weapon sockets, and approximate height.

Imported environment models are checked for meshes, StaticBody3D nodes,
CollisionShape3D nodes, and overall dimensions.

### Runtime LOD
External characters and environment models now use distance-based visibility,
shadow, and GI control. Far assets stop casting shadows and disappear beyond
the configured range.

### Developer overlay
Press F10 to display imported asset availability, validation warnings,
collision results, and instantiated-node information.

### Safe replacement
Procedural assets remain active unless an imported replacement loads and has
valid collision. This prevents invisible holes and duplicate decorative models.

### Compatibility
- Build: v7.3.0
- Protocol: 341
- Explicit connection-message `+` retained
- Missing assets continue using fallbacks
