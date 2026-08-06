# Frontline: Objective

## Version 5.6.1 Headless Import Hotfix

### Critical startup fix
The v5.6.0 build used parse-time `preload()` calls for imported GLB scenes.
After `.godot` was deleted on the VPS, Godot had no generated `.scn` import
artifacts available. Because `preload()` runs while parsing the script, this
prevented `main.gd` from loading.

This hotfix removes all parse-time GLB preloads and restores the
cache-independent authoritative collision system from v5.5.2.

### Included
- Expanded ground collision
- Playable map perimeter
- Out-of-bounds recovery
- Gray/plaster wall collision
- Server-authoritative townhouse wall proxies
- Bot routing and stuck recovery
- Surface-aware footstep pitch and volume from v5.6.0

### Diagnostic correction
The broken exact-collision startup messages that displayed literal `%s` and
`%d` are removed along with the unsupported runtime import path.

### Compatibility
- Build: v5.6.1
- Protocol: 341
- Explicit connection-message `+` retained.

Expected status: `Connected: v5.6.1 protocol 341`
