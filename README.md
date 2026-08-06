# Frontline: Objective

## Version 5.2.1 Map Expansion Type-Inference Hotfix

### Fixed
Godot could not infer the type returned by `cover_data.rotated(...)` because
`cover_data` comes from a heterogeneous Array and is treated as a Variant.

The staging-cover loop now explicitly converts and types the value:

```gdscript
var cover_position: Vector3 = Vector3(cover_data)
var offset: Vector3 = cover_position.rotated(
    Vector3.UP,
    facing
)
```

Additional local variables introduced by the v5.2 map expansion are now
explicitly typed to reduce strict parser and inference errors.

### Compatibility
- Build: v5.2.1
- Protocol: 341
- Explicit connection-message `+` retained.
- All v5.2.0 map expansion, staging, sewer, route, and spawn features remain.

Expected status: `Connected: v5.2.1 protocol 341`
