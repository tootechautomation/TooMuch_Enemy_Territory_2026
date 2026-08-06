# Changelog

## 8.4.0
- Made impact decals independent of short-lived particle roots
- Extended bullet-hole visibility to the intended bounded lifetime
- Cached procedural impact textures to remove per-shot texture regeneration
- Added randomized radial fracture detail to bullet-hole decals
- Directed debris away from struck surfaces instead of always upward
- Added emissive ricochet streaks for metal impacts
- Preserved v8.3.2 world-root compatibility
- Preserved protocol 341 and explicit connection-string `+`

## 8.3.2
- Changed combat impact world_root parameter from Node3D to Node
- Added safe Node3D world-context discovery
- Added explicit Dictionary typing for the surface ray result
- Fixed runtime argument-type failure from main.gd
- Preserved all v8.3 combat effects
- Preserved protocol 341 and explicit connection-string `+`
