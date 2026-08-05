# Frontline: Objective

## Version 3.4.1 skin script resolution fix

This release corrects the dependency resolution error introduced in v3.4.0.

Fixed:

- `constructible.gd` now begins with `extends StaticBody3D`.
- `field_emplacement.gd` now begins with `extends Node3D`.
- `destructible_cover.gd` now begins with `extends StaticBody3D`.
- Texture preload constants now appear after each `extends` declaration.
- Added a package validation pass that checks the first declaration of every GDScript file.

All v3.4.0 uniforms, weapon skins, object textures, and foliage sprites remain included.

Expected status:

```text
Connected: v3.4.1 protocol 341
```
