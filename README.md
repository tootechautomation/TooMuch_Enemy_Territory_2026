# Frontline: Objective

## Version 8.3.1 Combat Effects Type Hotfix

Godot returns `Variant` from `Array.pop_front()`. Because the project treats
warnings as errors, the inferred `oldest` variables prevented
`combat_effects_manager.gd` from parsing.

Both cleanup queues now use explicit casts:

```gdscript
var oldest: Decal = active_decals.pop_front() as Decal
var oldest: Node = active_effect_roots.pop_front() as Node
```

All v8.3 surface impacts, sparks, dust, fragments, explosion smoke, fireball,
scorch marks, and bounded cleanup behavior remain enabled.

Build: v8.3.1
Protocol: 341
