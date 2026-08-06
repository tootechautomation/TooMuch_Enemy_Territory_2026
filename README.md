# Frontline: Objective

## Version 8.2.1 Wall Probe Type Hotfix

The three-height server wall probe used inferred local variables. Godot could
not infer the type of `origin` from the loop value.

The probe now uses:

```gdscript
var probe_heights: Array[float] = [0.35, 0.95, 1.45]

for probe_height: float in probe_heights:
    var origin: Vector3 = (
        global_position
        + Vector3.UP * float(probe_height)
    )
```

The hit distance is also explicitly typed as `float`.

All v8.2 structural authority, fallback collision, wall sweep, and alley-detail
changes remain enabled.

Build: v8.2.1
Protocol: 341
