# External Asset Integration — v8.19

## Characters

```text
assets/external/characters/allied_soldier.glb
assets/external/characters/axis_soldier.glb
```

The v8.19 bridge also auto-detects these names:

```text
assets/external/characters/modular_military_2_allied.glb
assets/external/characters/modular_military_2_allied.fbx
assets/external/characters/modular_military_2_allied.blend
assets/external/characters/modular_military_2_axis.glb
assets/external/characters/modular_military_2_axis.fbx
assets/external/characters/modular_military_2_axis.blend
```

For modular packs, assemble and skin one complete character per team before
export. GLB with embedded textures and animations is preferred. Godot imports
FBX and Blender sources, but a normalized GLB produces the most predictable
open-source build.

The free `Modular military 2 - Demo.zip` is only a cooked Unreal Engine 4
Windows evaluation build. It contains a packaged `.pak`, not editable FBX,
GLB, Blender, or texture sources, so it cannot be used as a Godot character
asset. Do not unpack or redistribute its cooked content. Use the source files
from the licensed full character package when available.

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

Imported cloth surfaces whose mesh or material names include `uniform`,
`jacket`, `shirt`, `pants`, `trouser`, `sleeve`, `fabric`, `cloth`, or `body`
receive a restrained team-specific historical tint and minimum cloth
roughness. Skin, metal, leather, weapons, and equipment are left intact.

## Environment collision

Preferred: include authored `StaticBody3D` and `CollisionShape3D` nodes in the
GLB scene or inherited Godot scene.

Fallback: v7.2 can call `create_trimesh_collision()` on imported
`MeshInstance3D` nodes. This is accurate but heavier than simple authored
collision and should be replaced before final optimization.

Procedural stand-ins are hidden only after the real asset loads and has valid
collision. This prevents decorative models from creating holes in the map.
