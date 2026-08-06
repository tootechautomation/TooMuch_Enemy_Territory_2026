# Frontline: Objective

## Version 7.0.0 Real Asset Pipeline Foundation

### Real characters
The game can now instantiate optional rigged Allied and Axis GLB models. When a
real model is present, the procedural body is hidden automatically.

The animation adapter searches common animation names for:
- Idle
- Walk
- Run or sprint
- Crouch
- Reload
- Death or downed

### Real environment
Optional village houses, ruined buildings, warehouse, chainlink fence, and
military crate GLBs can now be loaded from `assets/external`.

### Collision reliability
- Wooden fences now have authoritative StaticBody3D collision on the VPS.
- Placeholder townhouses now use solid inset fallback volumes, preventing
  players and bots from passing through brick façades.
- Real imported environment assets can later use authored collision scenes.

### Asset workflow
A curated manifest and verifier are included:

```text
assets/external/asset_manifest.json
assets/external/README.md
tools/verify_external_assets.py
```

CC0 sources are preferred for distributable builds. CGTrader models can be used
when their individual license permits game incorporation, but raw source assets
should not be redistributed unless explicitly allowed.

### Compatibility
- Build: v7.0.0
- Protocol: 341
- Explicit connection-message `+` retained
- Missing external assets safely use procedural fallbacks

Expected status: `Connected: v7.0.0 protocol 341`
