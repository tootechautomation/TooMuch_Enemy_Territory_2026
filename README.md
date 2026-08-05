# Frontline: Objective

## Version 3.4.4 headless texture recovery

This release fixes the Linux server startup failure caused by imported PNG
textures being preloaded from missing `.godot/imported/*.ctex` files.

### Fixed

- Removed every PNG `preload()` from GDScript.
- Textures now load at runtime only when a graphical display is active.
- Headless servers use the same gameplay scripts without loading visual assets.
- Uniform, weapon, metal, wood, concrete and foliage textures remain enabled
  on Windows and graphical clients.
- `character_visual.gd` no longer requires the `SkinDefinition` global class
  cache to parse.
- Character skin resources load only on graphical clients.
- Added `tools/prepare_headless_server.sh` to delete stale cross-platform
  `.godot` caches and run one clean Linux import pass.

Build:

```text
v3.4.4
```

Compatible network protocol:

```text
341
```
