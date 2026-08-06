# Frontline: Objective

## Version 5.5.1 Parser Hotfix

Fixed an extra indentation level in `_bot_obstacle_ahead()` that caused Godot to report `Expected statement, found Indent instead`.

The corrected block is:

```gdscript
if not high_hit.is_empty():
    return false
```

Also normalized the route-hint ternary indentation for parser clarity. All v5.5.0 geometry alignment, gray-wall collision, bot route, and collision-audit features remain included.

- Build: v5.5.1
- Protocol: 341
- Explicit connection-message `+` retained.
