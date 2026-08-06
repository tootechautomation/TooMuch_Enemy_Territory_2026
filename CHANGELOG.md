# Changelog

## 8.11.0
- Added an original synchronized calm, tension, and assault battlefield score
- Added smooth objective-driven intensity crossfades
- Raised score pressure for armed dynamite, contested control points, damaged objectives, overtime, and final-minute play
- Routed all score stems through the existing Music bus and profile volume control
- Lowered ambience slightly so the musical score remains clearly audible
- Preserved headless behavior, gameplay, networking, previous milestones, and protocol 341


## 8.10.0
- Rebound fallback animation to the articulated v8.7 shoulder, hip, knee, torso, head, and weapon joints
- Added speed-scaled locomotion, torso counter-motion, knee articulation, and equipment-aware posing
- Added supported aiming, crouched combat, asymmetric reload, idle breathing, and subtle look motion
- Added grounded incapacitated poses with clean recovery on respawn
- Preserved external rig animation, physics, hitboxes, combat timing, networking, and protocol 341


## 8.9.0
- Added detailed magazines, triggers, ejection ports, controls, barrel hardware, and sling fittings to fallback first-person weapons
- Added a detailed fallback pistol slide, chamber, sights, magazine, grip panels, and controls
- Added class-specific LMG, SMG, carbine, field-ops, and marksman weapon details
- Added a lowered and rolled first-person reload pose with subtle hand-work movement
- Preserved imported weapon overrides, combat balance, networking, earlier milestones, and protocol 341


## 8.8.0
- Added layered period facades with recessed doors, windows, stone bases, lintels, and sills
- Added iron balconies, warm street lamps, chimneys, and stronger roof silhouettes
- Added deterministic battle-damage rubble clusters around village and rail approaches
- Added reflective puddles and repaired road seams to break up broad flat surfaces
- Kept all new dressing non-blocking and disabled it on headless servers
- Preserved v8.7 soldier fidelity, Forward+ PBR, spatial audio, combat effects, and protocol 341


## 8.7.0
- Improved bundled Allied and Axis fallback soldier silhouettes
- Added team-specific helmet geometry, facial ears, and neck protection
- Added webbing straps, breast pockets, buttons, buckle, and layered equipment
- Replaced box-shaped boots and backpacks with rounded geometry
- Added rifle handguard, bolt handle, trigger guard, and canvas sling details
- Restricted uniform textures to cloth instead of skin, leather, wood, and metal
- Added distinct metallic response for helmets, rifle parts, and belt hardware
- Raised battlefield ambience from -24 dB to -15 dB and enabled seamless looping
- Preserved automatic external rigged-character and weapon replacement support
- Preserved all v8.6 Forward+ PBR rendering improvements
- Preserved protocol 341 and explicit connection-string `+`

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
