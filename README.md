# Frontline: Objective

## Version 4.8.1 Viewport API Hotfix

This hotfix corrects the resolution-safe HUD viewport lookup.

### Fixed
`CharacterBody3D` does not provide `get_viewport_rect()`. The HUD scaler now
retrieves the active viewport and reads its visible rectangle:

```gdscript
var viewport: Viewport = get_viewport()
if viewport == null:
    return
var viewport_size: Vector2 = viewport.get_visible_rect().size
```

All v4.8.0 HUD scaling, compass cleanup, world-marker cleanup, spawn-beam
cleanup, gameplay systems, and visual assets remain included.

### Compatibility
- Build: v4.8.1
- Protocol: 341
- Explicit connection-message `+` retained.

Expected status: `Connected: v4.8.1 protocol 341`
