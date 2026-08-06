# Changelog

## 8.6.0
- Upgraded the desktop renderer from GL Compatibility to Forward+
- Enabled 4x MSAA, screen-space antialiasing, and soft directional shadows
- Enabled screen-space reflections and cinematic contrast/color grading
- Connected existing albedo, normal, and roughness maps to the material library
- Added true PBR surfaces for ten battlefield material categories
- Replaced box-shaped sandbags with rounded capsule geometry
- Replaced box rubble with low-poly irregular stone geometry
- Preserved the GL Compatibility renderer as the mobile fallback
- Preserved all v8.5 spatial combat audio and functional audio buses
- Preserved protocol 341 and explicit connection-string `+`

## 8.5.0
- Added positional surface-impact audio for every replicated bullet hit
- Added distinct metal, wood, brick, concrete, stone, ground, and flesh profiles
- Added randomized pitch variation to reduce repetitive combat sound
- Cached synthesized impact streams instead of generating audio per shot
- Added a bounded 28-player impact-audio pool for sustained firefights
- Created functional SFX and Music buses for the existing profile sliders
- Routed weapons, reloads, footsteps, hit confirms, grenades, and explosions to SFX
- Routed battlefield ambience to Music
- Preserved all v8.4 persistent decals and directional impact effects
- Preserved protocol 341 and explicit connection-string `+`

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
