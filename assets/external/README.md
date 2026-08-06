# External Asset Integration — v7.2

## Characters

```text
assets/external/characters/allied_soldier.glb
assets/external/characters/axis_soldier.glb
```

The character should include a hand or weapon attachment node named one of:

```text
WeaponSocket
weapon_socket
RightHandSocket
hand_r
```

## Weapons

```text
assets/external/weapons/allied_rifle.glb
assets/external/weapons/axis_rifle.glb
assets/external/weapons/service_pistol.glb
```

The correct weapon is attached to the current character socket and changes
when the replicated weapon index changes.

## Environment collision

Preferred: include authored `StaticBody3D` and `CollisionShape3D` nodes in the
GLB scene or inherited Godot scene.

Fallback: v7.2 can call `create_trimesh_collision()` on imported
`MeshInstance3D` nodes. This is accurate but heavier than simple authored
collision and should be replaced before final optimization.

Procedural stand-ins are hidden only after the real asset loads and has valid
collision. This prevents decorative models from creating holes in the map.
